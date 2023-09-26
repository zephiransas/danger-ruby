module Danger
  class CodeReview < Plugin
    def code_review
      (git.modified_files + git.added_files).select { |file_path| target?(file_path) }.each do |file_path|
        unified_diff = git.diff_for_file(file_path).patch
        review_diff(file_path, unified_diff).each do |result|
          warn('ActiveRecordのorが使用されています', file: result[:file_path], line: [:line_number])
        end
      end
    end

    def review_diff(file_path, unified_diff)
      git_start_line = /^@@ .+\+(?<line_number>\d+)/
      git_modified_line = /^\+[^+]*$/
      git_deleted_line = /^-/
      git_ignore_line = /^\\ No newline at end of file$/

      line_number = 0
      result = []

      unified_diff.split("\n").each do |line|
        start_line_number = 0
        case line
        when git_start_line
          # diffが行番号を示す場合は、行番号を取得
          start_line_number = start_line_number(line)
        when git_modified_line
          # 対象の文字列があれば、そのファイル名と行番号を結果にappend
          result.append({ file_path: file_path, line_number: line_number }) if /\.or/.match?(line)
        when git_deleted_line
          next  # 修正後のファイル行数が基準になるため削除行はカウントに含めない。
        when git_ignore_line
          next  # 不要な行なので無視
        end

        if line_number > 0
          line_number += 1
        elsif start_line_number > 0 && line_number == 0
          line_number = start_line_number
        else
          next
        end
      end
      result
    end

    def target?(file_path)
      pattern = 'app/models/*.rb' # app/models/*.rbファイルのみ対象とする
      regex = Regexp.new('\A' + Regexp.escape(pattern).gsub('\*', '.*') + '\z')
      regex.match?(file_path)
    end

    def start_line_number(line)
      git_start_line = /^@@ .+\+(?<line_number>\d+)/
      regex = Regexp.new(git_start_line)
      m = regex.match(line)
      if m
        m[:line_number].to_i
      else
        0
      end
    end
  end
end
