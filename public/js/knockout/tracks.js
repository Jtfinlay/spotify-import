/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2016 James Finlay
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

function Track(data) {
      var self = this;
      data = data || {};

      self.title = data.title;
      self.artist = data.artist;
      self.album = data.album;
      self.results = "";
      self.spotify_id = "";
      self.g_id = data.dataid;
}

function TracksViewModel() {
      var self = this;

      self.tracks = ko.observableArray();
      self.trackCount = ko.observable(0);

      self.populateData = function() {
        $.get("/importTracks", function (data) {
            self.tracks([]);

            $.each(JSON.parse(data), function(i, track) {
                self.tracks.push(new ko.observable(Track(track)));
            });
            self.trackCount(self.tracks().length)
            vm.querySpotifyData(0);
        });
      };

      self.querySpotifyData = function(index) {
        var item = self.tracks()[index];
        if (typeof item === "undefined")
            return;
        $.get("/spotifyData", item)
            .done(function(data) {
                alert(JSON.parse(data)["count"];)
                self.tracks()[index].results = JSON.parse(data)["count"];
            });
      }
}

var vm = new TracksViewModel();
$(function() {
      ko.applyBindings(vm);
});

vm.populateData();