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

require 'net/http'
require 'json'
require_relative 'custom_exceptions'

class SpotifyHelper

    API_URL = "https://api.spotify.com/v1/"

    REDIRECT_URL = 'http://localhost:8888/callback'

    AUTHENTICATION_URL = 'https://accounts.spotify.com/authorize'
    AUTHENTICATION_SCOPES = 'user-library-read user-library-modify'

    TOKEN_URL = 'https://accounts.spotify.com/api/token'

    #
    # Build the uri needed for Spotify Authentication. The auth will redirect
    # to /callback on completion.
    #
    def self.SpotifyOAuthUrl
        return AUTHENTICATION_URL +
                '?response_type=code' +
                '&client_id=' + CLIENT_ID +
                '&scope=' + URI.encode(AUTHENTICATION_SCOPES) +
                '&redirect_uri=' + REDIRECT_URL
    end

    #
    # From the Spotify Authentication response, perform the token authorization process
    #
    # request: Spotify Authentication response containing an authorization code or error
    #
    def self.HandleTokenAuthorization(request)
        if not request['error'].nil?
            raise AuthenticationException, request['error']
        end

        code = request['code']
        res = Net::HTTP.post_form(URI(TOKEN_URL),
            'grant_type' => 'authorization_code',
            'code' => code,
            'redirect_uri' => REDIRECT_URL,
            'client_id' => CLIENT_ID,
            'client_secret' => CLIENT_SECRET)

        if not res.code.to_i == 200
            raise TokenAuthorizationException, res.message
        end

        return JSON.parse(res.body)
    end

    #
    # Perform GET query for the specific uri that requires access_token
    #
    def self.PerformRestrictedGet(access_token, uri)
        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = "Bearer #{access_token}"

        res = Net::HTTP.start(uri.hostname, uri.port,
            :use_ssl => uri.scheme == 'https') do |http|
            http.request(req)
        end

        return JSON.parse(res.body)
    end

    #
    # Perform GET query to access user profile information
    #
    def self.GetProfileData(access_token)
        uri = URI(API_URL + 'me')

        return SpotifyHelper.PerformRestrictedGet(access_token, uri)
    end

    #
    # Perform GET query to access user library
    #
    def self.GetUserLibrary(access_token)
        uri = URI(API_URL + 'me/tracks')

        return SpotifyHelper.PerformRestrictedGet(access_token, uri)
    end

    #
    # Perform GET query to search for track by name, artist, album
    #
    # track_name: Track to query
    # artist: Name of artist
    # album: Name of album containing track
    #
    def self.SearchTrack(track_name, artist, album)
        url = API_URL + 
            "search?type=track&q=" +
            "track:#{track_name}" +
            " artist:#{artist}" +
            " album:#{album}"

        content = Net::HTTP.get(URI(URI.encode(url)))
        return JSON.parse(content)
    end

end
