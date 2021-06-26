require_relative 'line_renderer_html'

module Rendering
  class LineRendererJekyll < LineRendererHTML

    def render_code(content)
      "<code>#{content.gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')}</code>"
    end

    def render_strongunderscore(content)
      %Q{<strong class="text-purple-100 fw-500">#{content}</strong>}
    end

    def render_strongstar(content)
      %Q{<strong class="text-grey-dk-000 fw-500">#{content}</strong>}
    end

    def render_emphasisunderscore(content)
      %Q{<em class="text-purple-100 fw-500">#{content}</em>}
    end

    def render_emphasisstar(content)
      %Q{<em class="text-grey-dk-000 fw-300">#{content}</em>}
    end
  end
end