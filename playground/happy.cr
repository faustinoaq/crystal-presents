
嬉しい = -> (message : String) : Nil {
  3.times {|i|
    print "#{i} #{message}\n"
  }
}

嬉しい.call "Happy!, pronounced Ureshii!"
