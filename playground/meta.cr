
require "./llm"

METHOD = [] of String
macro method_missing(call)
  METHOD.unshift {{call.name.stringify}}
end

def faustino(*args)
  LLM.call METHOD.join " "
end

faustino how is metaprograming possible?

