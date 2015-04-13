class HomeController < ApplicationController
	skip_before_filter  :verify_authenticity_token
  require 'symmetric-encryption'
SymmetricEncryption.load!('config/symmetric-encryption.yml', 'development')




  def index
      pathh= Rails.root.join('jadee.jpeg')
      puts pathh

  end

  def upload
  	puts "upload submitted8*******************************************************************"
  	uploaded_io = params[:file]
    # File.open(Rails.root.join(uploaded_io.original_filename), 'wb') do |file|
    #   file.write(uploaded_io.read)
    # end
          SymmetricEncryption::Writer.open(Rails.root.join(uploaded_io.original_filename)) do |file|
            file.write(uploaded_io.read)
          end
 	  render json: { message: "success" }, :status => 200
  end

  def boxaut
    require 'ruby-box'
    session = RubyBox::Session.new({
      client_id: 'skamrg791rspftegmigusyevx2pup49y',
      client_secret: '6sj2CBbfGU0eFdfJojTxJOu36DtVyKG6'
    })
    authorize_url = session.authorize_url('http://localhost:3000/home/boxauth')
    redirect_to authorize_url
  end

  def boxauth
      require 'ruby-box'
      session = RubyBox::Session.new({
        client_id: 'skamrg791rspftegmigusyevx2pup49y',
        client_secret: '6sj2CBbfGU0eFdfJojTxJOu36DtVyKG6'
      })
      code=params[:code]
      @token = session.get_access_token(code)
      tok= @token.token # the access token.

      # require 'boxr'

      # client = Boxr::Client.new(tok)  #using ENV['BOX_DEVELOPER_TOKEN']
      # file = client.upload_file(Rails.root.join('index.jpeg'), 'csc')

      session = RubyBox::Session.new({
        client_id: 'skamrg791rspftegmigusyevx2pup49y',
        client_secret: '6sj2CBbfGU0eFdfJojTxJOu36DtVyKG6',
        access_token: tok
      })
      client = RubyBox::Client.new(session)
      # file = client.upload_file('./index.jpeg','csc') # lookups by id are more efficient
      # file = client.upload_file_by_folder_id('index.jpeg', '3424018546') 

      pathh= Rails.root.join('jadee.jpeg')
      pathhh=pathh.to_s
  file = client.upload_file(pathhh, '/csc', overwrite=true) # lookups by id are more efficient

      
      redirect_to home_index_path  

  end


  def encrypt
    SymmetricEncryption::Writer.open('encrypted_file') do |file|
        file.write "Hello World\n"
        file.write "Keep this secret"
      end
    # File.open(Rails.root.join('index.jpeg'), 'r') do |dfile|
    #     SymmetricEncryption::Writer.open(Rails.root.join('index1.jpeg')) do |file|
    #            dfile.each_line do |line|
    #              file.write line
    #           end
            
    #       end
    # end
    redirect_to home_index_path
  end

  def decrypt
     SymmetricEncryption::Reader.open('encrypted_file') do |file|
          file.each_line do |line|
             puts line
          end
    end
      redirect_to home_index_path
  end

end
