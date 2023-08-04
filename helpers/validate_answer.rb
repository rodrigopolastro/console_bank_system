def affirmative?(yes_no_answer)
  yes_no_answer.downcase.match?(/^(y|yes)$/)
end

def negative?(yes_no_answer)
  yes_no_answer.downcase.match?(/^(n|no)$/)
end
