require 'sinatra'
require 'fileutils'
require 'tempfile'

Episode = Struct.new(:num, :dir) do
  def self.all where = 'episodes'
    Dir.entries(where).map do |dir|
      if dir =~ /^(\d+)/
        ep_num = $1.to_i
        self.new ep_num, File.join(where, dir)
      end
    end.compact.reverse
  end

  def self.unwatched
    all.reject(&:watched?)
  end

  def self.find_by_number num
    all.find { |ep| ep.num == num.to_i }
  end

  def html_body
    File.read File.join(dir, 'index.html')
  end

  def video_url
    @url ||= File.read File.join(dir, 'video-url')
  end

  def local_video_url
    "media/#{File.basename video_url}"
  end

  def has_video?
    File.exist? "public/#{local_video_url}"
  end

  def watched_indicator
    File.join(dir, 'watched')
  end

  def watched?
    File.exist? watched_indicator
  end
end

helpers do
  def mark_as_watched_path episode
    "/watched/%d" % episode.num
  end

  def download_path episode
    "/download/%d" % episode.num
  end
end

get '/' do
  erb :index, locals: { episodes: Episode.unwatched }
end

get '/all' do
  erb :index, locals: { episodes: Episode.all }
end

post '/watched/:ep_num' do
  ep = Episode.find_by_number params[:ep_num]
  FileUtils.touch ep.watched_indicator
  redirect params[:redirect_to] || back
end

post '/download/:ep_num' do
  ep = Episode.find_by_number params[:ep_num]
  tracefile = Tempfile.new("#{ep.num}.trace")
  system %(./fetch "#{ep.video_url}" "public/#{ep.local_video_url}" --trace-ascii "#{tracefile.path}" &)
  "/download/progress?tracefile=#{tracefile.path}"
end

get '/download/progress' do
  total_bytes = 0
  received_bytes = 0

  File.open(params[:tracefile], 'r') do |trace|
    trace.each do |line|
      if line.start_with? "0000: "
        total_bytes = $1.to_i if line =~ /^0000: content-length: (\d+)/i
      elsif line.start_with? "<= Recv data" and line =~ /(\d+)/
        received_bytes += $1.to_i
      end
    end
  end

  (received_bytes / total_bytes.to_f).to_s
end

get '/tapas.css' do
  sass :style
end

__END__
@@ index
<h1>RubyTapas</h1>
<a href="/all">All</a>
<a href="/">Unwatched</a>
<ol>
  <% for ep in episodes %>
  <li<%= ep.watched?? ' class=watched' : '' %>>
  <%= ep.html_body %>
  <form action="<%= mark_as_watched_path ep %>" method=post>
    <% if ep.has_video? %>
    <button type=submit name=redirect_to value="<%= ep.local_video_url %>">Watch episode</button>
    <% end %>
    <% unless ep.watched? %>
    <button type=submit>Mark watched</button>
    <% end %>
  </form>
  <% unless ep.has_video? %>
  <form action="<%= download_path ep %>" method=post>
    <button type=submit>Download</button>
  </form>
  <% end %>
  </li>
  <% end %>
</ol>

<script>
function monitorProgress(form, url, percent) {
  var num = parseInt(percent * 100)
  $(form).find('button').first().text("Downloading: " + num + "%")
  if (num < 100) setTimeout(function(){
    $.get(url, function(newPercent){
      monitorProgress(form, url, parseFloat(newPercent))
    })
  }, 2000)
}

$(document).on('submit', 'form[action^="/download"]', function(){
  var form = $(this)
  form.find('button').attr('disabled', true)
  $.post(form.attr('action'), function(progressUrl){
    monitorProgress(form, progressUrl, 0)
  })
  return false
})
</script>

@@ layout
<!doctype html>
<link rel="stylesheet" href="tapas.css">
<meta content='initial-scale=1.0' name='viewport'>
<script src=zepto.min.js></script>
<%= yield %>

@@ style
body
  font: medium helvetica, sans-serif
  padding: 2em 4em
ol
  list-style: none
ol > li
  margin-bottom: 2em
  &.watched
    color: gray
    a
      color: inherit
ol h1
  font-size: 1.2em
ol h3
  font-size: 1em

form
  margin-top: 1em
