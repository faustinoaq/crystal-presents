require "http/client"
require "json"
require "openssl"
require "dotenv"

Dotenv.load

OPENAI_ENDPOINT     = ENV["OPENAI_ENDPOINT"]
CHALLENGER_ENDPOINT = ENV["CHALLENGER_ENDPOINT"]
OPENAI_API_KEY      = ENV["OPENAI_API_KEY"]
CHALLENGER_API_KEY  = ENV["CHALLENGER_API_KEY"]
CONTEXT             = File.read("context.txt")
LLAMA3              = "llama-3-8b-instruct"
GPT35T              = "gpt-3.5-turbo"

LLM = ->(question : String) {
  api_key = CHALLENGER_API_KEY
  endpoint = CHALLENGER_ENDPOINT
  model = LLAMA3
  max_tokens = 200

  payload = {
    messages: [{"role": "user", "content": "You are a helpful assistant who needs to answer in a simple way and ask no questions in less than #{max_tokens} tokens, and you have the following context about me: #{CONTEXT}"},
               {"role": "assistant", "content": "Ok I'll help you to answer in a simple way and ask no questions about you"},
               {"role": "user", "content": question}],
    max_tokens: max_tokens,
    model:      model,
    stream:     true,
  }.to_json

  headers = HTTP::Headers{
    "content-type"  => "application/json",
    "Authorization" => "Bearer #{api_key}",
  }

  ssl_context = OpenSSL::SSL::Context::Client.new
  ssl_context.verify_mode = OpenSSL::SSL::VerifyMode::NONE

  client = HTTP::Client.new(endpoint, port: 443, tls: ssl_context)

  client.post("/v1/chat/completions",
    headers: headers,
    body: payload
  ) { |resp|
    while line = resp.body_io.gets
      break if line == "data: [DONE]"
      line = line.lchop("data: ")
      next if line.empty?
      begin
        data = JSON.parse(line)
        if delta = data["choices"][0]["delta"]?
          if content = delta["content"]?
            print content
          end
        end
      rescue
        print line
      end
    end
  }
}
