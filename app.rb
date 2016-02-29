# The MIT License (MIT)
#
# Copyright (c) 2016 James Finlay
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'sinatra'
require_relative 'helpers/api_keys'
require_relative 'helpers/spotify_helper'

class SpotifyImporter < Sinatra::Base

    enable :sessions

    helpers do
        def authenticated?
            not session[:access_token].nil?
        end

        def spotifyTrackCount
            SpotifyHelper.GetUserLibrary(session[:access_token])["total"]
        end

        def stromaeTest
            res = SpotifyHelper.SearchTrack('formidable', 'stromae', 'Racine Carrée')
            return res['tracks']['items'][0]['id']
        end

    end

    get '/' do
        erb :home
    end

    get '/callback' do
        begin
            helper = SpotifyHelper.new
            helper.HandleTokenAuthorization(request)

            user_data = helper.GetProfileData
            session['user_name'] = user_data["id"]

            redirect to('/')

        rescue Exception => detail
            return "Error: #{detail}"
        end
    end

    get '/authenticate' do
        redirect to(SpotifyHelper.SpotifyOAuthUrl)
    end



end