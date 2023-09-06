pattern = 'app/models/*.rb'
regex_pattern = Regexp.new('\A' + Regexp.escape(pattern).gsub('\*', '.*') + '\z')

git_start_line = /^@@ .+\+(?<line_number>\d+),/ 
git_modified_line = /^\+/
git_deleted_line = /^\-/

(git.modified_files + git.added_files).each do |file|
  
  next unless regex_pattern.match?(file)
  
  puts "######################"
  puts file
  puts "----------------------"
  puts git.diff_for_file(file).patch
  puts "######################"

  line_number = 0

  git.diff_for_file(file).patch.split("\n").each do |line|
    start_line_number = 0
    case line
    when git_start_line
        # 変更開始位置を示す行だった場合は何行目の変更か?を抜き出す
        start_line_number = Regexp.last_match[:line_number].to_i
    when git_modified_line
      puts "line number = #{line_number}"
      puts line

      warn("sample message", file: file, line: line_number)
    
        # 変更された行にキーワードが含まれていたら検知した情報を配列に追加
        # keyword_matched = line.match(Regexp.union(keywords))
        # if !keyword_matched.nil? then
        #     info << ReviewInfo.new(file_path, line_number, keyword_matched.to_a, git_info.patch)
        # end
    when git_deleted_line
        # 修正後のファイル行数が基準になるため削除行はカウントに含めない。
        next
    end

    if line_number > 0 then
      line_number += 1
    elsif start_line_number > 0 && line_number == 0 then
      line_number = start_line_number
    else
      next
    end
  
  end
end

#warn('Hello from Danger')