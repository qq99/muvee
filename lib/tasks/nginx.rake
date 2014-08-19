namespace :nginx do
  task :restart do
    %x{pkill nginx} # kills only ones we have access to by default
    %x{nginx -c #{Dir.getwd() + "/muvee.nginx.conf"}}
  end
end
