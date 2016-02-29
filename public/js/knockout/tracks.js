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

      self.dummy = ko.observable();

      self.title = data.title;
      self.artist = data.artist;
      self.album = data.album;
      self.results = ko.observable();
      self.spotify_id = ko.observable("");

      self.className = ko.computed(function() {
            if (self.results() >= 10)
                return "alert alert-warning";
            else if (self.results() > 0)
                return "alert alert-success";
            else if (self.results() === 0)
                return "alert alert-danger";
            else
                return "alert";
      });

      self.glyphicon = ko.computed(function() {
            if (self.results() >= 10)
                return "glyphicon glyphicon-warning-sign";
            else if (self.results() === 0)
                return "glyphicon glyphicon glyphicon-remove";
      });
}

function TracksViewModel() {
      var self = this;

      self.tracks = ko.observableArray();
      self.trackCount = ko.observable(0);
      self.trackIndex = ko.observable(0);
      self.readyToTransfer = ko.observable(false);

      self.populateData = function() {
        $.get("/importTracks", function (data) {
            self.tracks([]);

            $.each(JSON.parse(data), function(i, track) {
                self.tracks.push(new Track(track));
            });
            self.trackCount(self.tracks().length)
            vm.querySpotifyData(0);
        });
      };

      self.querySpotifyData = function(index) {
        var item = self.tracks()[index];
        if (typeof item === "undefined")
        {
          self.readyToTransfer(true);
          return;
        }
        $.get("/spotifyData", item)
            .done(function(data) {
                data = JSON.parse(data);
                self.tracks()[index].results(data["count"]);
                self.tracks()[index].spotify_id(data["spId"]);
                self.trackIndex(index+1);
                vm.querySpotifyData(index+1);
            });
      };

      self.transferTrackToSpotify = function(index) {

        $.post("/transferTrack", {}, function(data) { console_log(data); })
      }
}

var vm = new TracksViewModel();
$(function() {
      ko.applyBindings(vm);
});

vm.populateData();
vm.transferTrackToSpotify();