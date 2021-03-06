module VIM
  Dirs = %w[ autoload tmp/undo tmp/backup tmp/swap tmp/download ]
end

home = Dir.home
cwd = File.expand_path("../", __FILE__)
vim_dir = "#{home}/.vim"

task :req_dirs do
  VIM::Dirs.each do |dir|
    directory dir
  end
end

def fancy_output(message)
  n = message.length
  puts "*" * (n + 5)
  puts "*#{message.center(n + 3)}*"
  puts "*" * (n + 5)
end

desc "Init pavlim and update vim plugins"
task :init => :req_dirs do
  fancy_output "Updating all plugins"
  system "git submodule update --init"
end

desc "Update Pavlim"
task :update_pavlim do
  fancy_output "Pulling latest version"
  system "git pull git://github.com/PaBLoX-CL/Pavlim.git"
end

desc "Backup original vim dotfiles"
task :backup do
  fancy_output "Backing up your old files..."
  %w[ vim vimrc gvimrc ].each do |file|
    file = "#{home}/.#{file}"
    next if file == vim_dir
    if File.exists?(file) and not File.symlink?(file)
      mv file, "#{file}.old", verbose: true
    else File.symlink?(file)
      old_dest = File.readlink(file)
      if File.readlink(file).include? vim_dir
        ln_sf "#{vim_dir}.old/#{File.basename(old_dest)}", "#{file}.old", verbose: true
        rm file, verbose: true
      elsif
        copy_entry file, "#{file}.old"
        rm file, verbose: true
      end
    end
  end
end


def install_plugin(name, download_link=nil)

  namespace :plugin do

    @cwd = Dir.getwd
    @tmp_dir = "#{@cwd}/tmp/download"
    @bundle_dir = "#{@cwd}/bundle"

    def string_exists?(name)
      f = open("#{@cwd}/.git/info/exclude", 'r')
      true unless f.grep(/#{name}/).empty?
    end

    def ignore_local(name)
      unless string_exists?(name)
        open("#{@cwd}/.git/info/exclude", 'a') do |f|
          f << "\nbundle/#{name}/"
        end
      end
    end

    desc "Install #{name} plugin"
    task name => :req_dirs do

      if download_link

        if download_link.include?("vim.org")
          filename = %x(curl --silent --head #{download_link} | grep attachment).strip![/filename=(.+)/,1]
        else
          filename = File.basename(download_link)
        end

        system "curl #{download_link} > tmp/download/#{filename}"

        case filename
        when /\.zip$/
          system "unzip -o tmp/download/#{filename} -d bundle/#{name}"
        when /\.vim$/
          mkdir_p "#{Dir.getwd}/bundle/#{name}/plugin"
          mv "#{tmp_dir}/#{filename}", "#{bundle_dir}/#{name}/plugin/", verbose: true
        when /tar\.gz$/
          mkdir_p "#{tmp_dir}/#{name}"
          mkdir_p "#{bundle_dir}/#{name}"
          dirname = File.basename(filename, '.tar.gz')

          system "tar xf #{tmp_dir}/#{filename} -C #{tmp_dir}/#{name}"

          puts "Moving from tmp/download/#{name}/#{dirname} to bundle/#{name}"
          mv Dir["#{tmp_dir}/#{name}/#{dirname}/*"], "#{bundle_dir}/#{name}", force: true
        end

      else

        yield if block_given?

      end

      ignore_local name

    end
  end
end

install_plugin "scratch",       "http://www.vim.org/scripts/download_script.php?src_id=2050"
install_plugin "conque-shell",  "http://conque.googlecode.com/files/conque_2.3.tar.gz"

install_plugin "janus-themes" do
  # https://github.com/carlhuda/janus/blob/master/Rakefile
  # Custom version of railscasts theme
  unless File.exists? "#{cwd}/bundle/color-sampler/colors/railscasts.vim"
    puts "You have to install the color-sampler plugin first"
  end

  # TODO: I don't understand why the Rake::DSL#directory
  # doesn't work and I have to use mkdir_p
  mkdir_p "bundle/janus-themes/colors"

  File.open(File.expand_path("../bundle/janus-themes/colors/railscasts+.vim", __FILE__), "w") do |file|
    file.puts <<-VIM.gsub(/^ +/, "").gsub("<SP>", " ")
      runtime colors/railscasts.vim
      let g:colors_name = "railscasts+"

      set fillchars=vert:\\<SP>
      set fillchars=stl:\\<SP>
      set fillchars=stlnc:\\<SP>
      hi  StatusLine guibg=#cccccc guifg=#000000
      hi  VertSplit  guibg=#dddddd
    VIM
  end

  # Custom version of jellybeans theme
  File.open(File.expand_path("../bundle/janus-themes/colors/jellybeans+.vim", __FILE__), "w") do |file|
    file.puts <<-VIM.gsub(/^      /, "")
      runtime colors/jellybeans.vim
      let g:colors_name = "jellybeans+"

      hi  VertSplit    guibg=#888888
      hi  StatusLine   guibg=#cccccc guifg=#000000
      hi  StatusLineNC guibg=#888888 guifg=#000000
    VIM
  end
end

if File.exists?(custom_rake = "#{cwd}/custom.rake")
  puts "Loading custom rake file"
  import(custom_rake)
end

desc "Link (g)vimrc to ~/.(g)vimrc"
task :link_vim_files do
  fancy_output "Linking files"
  ln_sf(cwd, vim_dir, verbose: true) unless vim_dir == cwd
  %w[ vimrc gvimrc vimrc.before vimrc.after ].each do |file|
    dest = "#{home}/.#{file}"
    src = "#{vim_dir}/#{file}"
    if File.exists?(file)
      ln_sf src, dest, verbose: true
    end
  end
end

desc "Update documentation"
task :update_docs do
  fancy_output "Updating Vim documentation..."
  system "vim -c 'call pathogen#helptags()|q'"
end

task :default => [
  :link_vim_files,
  :update_docs
]

desc "Install the distribution: get the plugins, backup your old files and link the new ones"
task :install => [
  :backup,
  :init,
  :default
] do
  puts """Your old files have been appended with .old.
    Enjoy Pavlim and please don't forget to feedback, specially if something
    isn't working as it should ( :"""
end

desc "Updates Pavlim and the plugins"
task :update => [
  :update_pavlim,
  :init,
  :default
]
