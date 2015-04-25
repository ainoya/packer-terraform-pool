require 'erb'

@access_key =            ENV['AWS_ACCESS_KEY_ID']
@secret_key =            ENV['AWS_SECRET_ACCESS_KEY']
@region     =            ENV['AWS_DEFAULT_REGION']
@subnet_id  =            ENV['AWS_PACKER_SUBNET_ID']
@security_group_id =     ENV['AWS_PACKER_SG_ID']
@packer_ssh_private_ip = ENV['PACKER_SSH_PRIVATE_IP']

@tfvars = {
  sg_id:     ENV['TF_SG_ID'],
  region:    ENV['TF_REGION'] || ENV['AWS_DEFAULT_REGION'],
  subnet_id: ENV['TF_SUBNET_ID'],
}

@pool = {
  max_containers:          ENV['MAX_CONTAINERS'] || 10,
  preview_repository_url:  ENV['PREVIEW_REPOSITORY_URL'] || 'http://github.com/mookjp/flaskapp.git',
  pool_base_domain:        ENV['POOL_BASE_DOMAIN'] || 'pool.dev',
  github_bot:              ENV['GITHUB_BOT'] || 'false'
}

def terraform(task)
  cmd = %Q(terraform #{task} -input=false \
              -var "aws_access_key=#{@access_key}" \
              -var "aws_secret_key=#{@secret_key}" \
              -var "ami=#{@ami_id}" \
              -var "prod.sg_id=#{@tfvars[:sg_id]}" \
              -var "prod.region=#{@tfvars[:region]}" \
              -var "prod.subnet_id=#{@tfvars[:subnet_id]}" )
   cmd += case task
          when 'plan'
            '-out plan'
          when 'apply'
            '< plan'
          when 'destroy'
            ''
          else
            raise 'invalid task'
          end
   sh cmd
end

task :plan => :cloud_config do
  @ami_id = File.readlines('ami-id').first.chomp
  Dir.chdir("terraform") do
    terraform("plan")
  end
end

task :apply => :plan do
  @ami_id = File.readlines('ami-id').first.chomp
  Dir.chdir("terraform") do
    terraform("apply")
    puts "discovery url: #{@discovery_url}"
  end
end

task :destroy do
  @ami_id = File.readlines('ami-id').first.chomp
  Dir.chdir("terraform") do
    terraform("destroy")
  end
end

task :show do
  @ami_id = File.readlines('ami-id').first.chomp
  Dir.chdir("terraform") do
    sh %Q{terraform show}
  end
end

task :discovery_url do
	@discovery_url=`curl -s https://discovery.etcd.io/new?size=1`.chomp
  puts "discovery url: #{@discovery_url}"
  File.write('./discovery_url', @discovery_url)
end

task :cloud_config => :discovery_url do
  userdata_path = './terraform/userdata/pool-userdata.yaml'
  File.write(userdata_path, ERB.new(File.read("#{userdata_path}.erb")).result(binding))
end

task :clean do
	sh "rm -f terraform/userdata/core-userdata" 
end

task :coreos_hvm_ami_id do
  json = `curl -s http://stable.release.core-os.net/amd64-usr/current/coreos_production_ami_all.json`
	@coreos_ami_id=`echo '#{json}' | jq -r '.amis[] | select(.name == \"#{@region}\") | .hvm'`.chomp
  puts @coreos_ami_id
end

task :ami => :coreos_hvm_ami_id do
  Dir.chdir("packer") do
    File.write('./core.json', ERB.new(File.read('./core.json.erb')).result(binding))

    sh %Q(packer build -machine-readable \
          -var "aws_access_key=#{@access_key}" \
          -var "aws_secret_key=#{@secret_key}" \
          -var "source_ami=#{@coreos_ami_id}" \
          -var "subnet_id=#{@subnet_id}" \
          -var "security_group_id=#{@security_group_id}" \
          -var "region=#{@region}" core.json | tee ../build.log)
  end

  @ami_id=`grep 'artifact,0,id' build.log | cut -d, -f6 | cut -d: -f2`.chomp
  File.write('ami-id', @ami_id)
  puts @ami_id
end

task :all => [:ami, :apply]
