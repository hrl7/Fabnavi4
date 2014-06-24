require "fabnavi_utils"
Gdworker::App.controllers :project do

  get "/new" do
    id = params[:projectname]
    if id == nil then
      id = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    end

    res = Project.find_by(:project_name => id)
    if not res == nil then
      id = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    end
    res = id.to_s
    return {:id => res}.to_json
  end

  post "/postConfig" do
    data = params[:data]
    imgURLs = JSON.parse data
    id = find_project(params[:author],params[:project_id]).id
    pictureURLs= Picture.pictures_list(id)
    imgURLs.each_with_index do |url,i|
      pict = pictureURLs.find_by(:url => imgURLs[i]["globalURL"])
      pict.order_in_project = i+1
      pict.save
    end
    "hoge"
  end

  get "/delete" do
   res = Project.find_project(params[:author],params[:project_id])
   res.try(:delete)
  end

  post "/setThumbnail" do
    index = params[:thumbnail]
    proj = Project.find_project(params[:author],params[:project_id]).readonly(false).first
    proj.thumbnail_picture_id = index.to_i+1
    proj.save
  end 

  post "/postPicture" do
    #TODO check the header of pict
    data = params[:data]
    id = params[:project_id]
    url = params[:url]
    pict = Base64.decode64(data)
    fileName =File.basename(/^http.*.JPG/.match(url)[0])
    filePath = id+'/'+fileName
    save_pict_S3(filePath,pict)
    return "https://s3-ap-northeast-1.amazonaws.com/files.fabnavi/"+filePath
  end 

  post "/new" do
    @projectName = params[:ProjectName]
    @authorName = session[:authorName]
    proj = Project.joins(:author).find_by(:authors=>{name:@authorName},:project_name =>@projectName)
    if proj == nil then
      author = Author.find_by(:email => session[:email], :name => @authorName)
      p = Project.new 
      p.author = author
      p.project_name = @projectName
      if p.save then 
        redirect_to "/update/"+@authorName+"/"+@projectName
      else 
        flash[:notice] = "Error Something."
        render "project/newProject"
      end 
    else 
      flash[:notice] = "Project name is Duplicated. Change project name"
      render "project/newProject"
    end
  end
end
