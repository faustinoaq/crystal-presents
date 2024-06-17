require "./llm"

QUESTION = [] of String

macro method_missing(call)
  QUESTION.unshift {{call.name.stringify}}
end

CACHE = [""]

def faustino(*args)
  CACHE[0] = QUESTION.join(" ")
  QUESTION.clear
  nil
end

at_exit { LLM.call CACHE[0] unless CACHE[0].empty? }
