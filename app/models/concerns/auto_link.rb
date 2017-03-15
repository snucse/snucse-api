module AutoLink
  #code from https://github.com/tenderlove/rails_autolink/blob/master/lib/rails_autolink/helpers.rb

  AUTO_LINK_RE = %r{
    (?: ((?:ed2k|ftp|http|https|irc|mailto|news|gopher|nntp|telnet|webcal|xmpp|callto|feed|svn|urn|aim|rsync|tag|ssh|sftp|rtsp|afs|file):)// | www\. )
    [^\s<\u00A0"]+
  }ix

  BRACKETS = { ']' => '[', ')' => '(', '}' => '{' }

  WORD_PATTERN = RUBY_VERSION < '1.9' ? '\w' : '\p{Word}'

  def auto_link(text)
    text.gsub(AUTO_LINK_RE) do
      scheme, href = $1, $&
      punctuation = []

      while href.sub!(/[^#{WORD_PATTERN}\/-=&]$/, '')
        punctuation.push $&
        if opening = BRACKETS[punctuation.last] and href.scan(opening).size > href.scan(punctuation.last).size
          href << punctuation.pop
          break
        end
      end

      link_text = href
      href = 'http://' + href unless scheme
      "<a href=\"#{href}\">#{link_text}</a>" + punctuation.reverse.join
    end
  end
end
