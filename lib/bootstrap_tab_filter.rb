class BootstrapTabFilter < Nanoc::Filter
  identifier :bootstrap_tab

  def run(content, params = {})
    tab_regex = /\|(.*?)\|\n(----.*?--end--)+/m

    ex_number = 0
    content.gsub(tab_regex) do |match|
      ex_number += 1
      tab_titles = match.split("\n").first.split("|").map(&:strip).reject(&:empty?)
      tab_contents = match.gsub(/--end--\Z/, '').split(/----(\w*)\n/).map(&:strip).reject(&:empty?)
      tab_contents.shift

      tab_titles_html = []
      tab_contents_html = []

      tab_titles.each_with_index do |title, index|
        active_class = index.zero? ? 'active' : ''
        tab_titles_html << "<li class=\"#{active_class}\"><a data-toggle=\"tab\" href=\"#content-#{ex_number}-#{index}\">#{title}</a></li>"

        language = tab_contents[index * 2]
        code = tab_contents[index * 2 + 1]

        tab_contents_html << "<div id=\"content-#{ex_number}-#{index}\" class=\"tab-pane fade in #{active_class}\"><pre><code class=\"language-#{language}\">#{code}</code></pre></div>"
      end

      "<div class=\"tabbable\"><ul class=\"nav nav-tabs\">" +
        tab_titles_html.join("\n") +
        "</ul><div class=\"tab-content\">" +
        tab_contents_html.join("\n") +
        "</div></div>"
    end
  end
end
