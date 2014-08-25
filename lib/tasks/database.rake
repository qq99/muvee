namespace :database do
  task :create do
    %{sudo bash}
    %{su - postgres}
    %{psql -c "create role muvee with createdb login password 'password1'"}
  end
end
