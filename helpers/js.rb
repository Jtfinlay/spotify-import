require 'sinatra/base'

# From https://github.com/daz4126/sinatra-head-cleaner/blob/master/sinatra/head_cleaner.rb
module Sinatra
    module JavaScripts

        def js(*args)
            @js ||= []
            @js = args
        end

        def javascripts(*args)
            js = []
            js << settings.javascripts if settings.respond_to?('javascripts')
            js << args
            js << @js if @js
            js.flatten.uniq.map do |script|
                path_to(script).map do |script|
                    "<script src=\"#{script}\"></script>"
                end
            end.join
        end

        def path_to script
            case script
            when :knockout then ["http://ajax.aspnetcdn.com/ajax/knockout/knockout-3.1.0.js",
                "/js/knockout/tracks.js"]
            else ["/js/" + script.to_s + ".js"]
            end
        end
    end

    helpers JavaScripts
end