class ClostridiaController < ApplicationController
  def browse
    params[:start]=params[:start].to_i
    params[:end]=params[:end].to_i
    puts(params)
    @limit = 50000
    @errors=[]
    # If parameters, do things else do nothing
    if (params[:start] && params[:end] && params[:chr])
      checkparams(params)
      if @errors.any?
        render 'index'
      else
        @annotations = Genomeannotation.search(annotation_render)
        if params[:cov]
          # For active datasets, each condition set is added to an array of data          
          @data=[]; @cond=[]
          4.times do |i|
            stress,time,tex=params["stress#{i+1}"],params["time#{i+1}"],params["tex#{i+1}"]
            if stress.size > 0 || time.size > 0          
              if tex && tex != ""
                tex=(tex == "None" ? 0 : 1) 
              else
                tex=nil
              end
              x={"stress"=>(stress.size > 0 ? stress : nil), "time"=>(time.size > 0 ? time : nil), "tex"=>tex}
              @cond[i]=[x["stress"],x["time"],x["tex"]]
              @plus,@minus = Coverage.search(annotation_render,@cond[i],i).group_by{|x| x["strand"]}.values
              @plus = method("cov_" << params[:reducer]).call(@plus.group_by{|x| x['base']})
              @minus = method("cov_" << params[:reducer]).call(@minus.group_by{|x| x['base']})


=begin              
              # PostgreSQL legacy code
              @plus,@minus=@coverages.map{|x|x.as_json}.group_by{|x|x["strand"]}.values

              @plus=eval("cov_#{params[:reducer]}(@plus.group_by{|x|x['base']})")

              @minus=eval("cov_#{params[:reducer]}(@minus.group_by{|x|x['base']})")
=end
              @data[i]=[@plus,@minus]
            end
          end

        end
      end
    end
  end

private

  def cov_Sum(results)
    # Results will be a hash of coverage hashes organized by base

    results.map {|b,o|
      c=o.map{|x|x["cov"].to_i}
      {"base"=>b,"cov"=>c.reduce(:+)} }
    # Reduced results will be an array of json objects ready to pass to javascript
  end

  def cov_Avg(results)
    results.map {|b,o| 
      c=o.map{|x|x["cov"].to_i}
      {"base"=>b,"cov"=>c.reduce(:+).to_f/c.size} }
  end

  def cov_Max(results)
    results.map {|b,o| 
      c=o.map{|x|x["cov"].to_i}
      {"base"=>b,"cov"=>c.max} }
  end

  def annotation_render
    [params.require(:chr),params.require(:start),params.require(:end)]
  end


  def annotation_params
    params.require(:annotation).permit(:name,:author,:chr,:feature,:start_site,:stop_site,:strand,:technique,:journal,:date);
  end

  def negDist?(start_site,stop_site)
    stop_site - start_site <= 0
  end

  def lessThanLimit?(start_site,stop_site)
    stop_site - start_site <= @limit + 1
  end

  def chrom?(chr)
    ['Chrom','pSol1'].include?(chr)
  end

  def stress?(params)
    valid=['','NS','BuOH','BA']
    valid.include?(params["stress1"]) && valid.include?(params["stress2"]) && valid.include?(params["stress3"]) && valid.include?(params["stress3"]) && valid.include?(params["stress4"])
  end

  def time?(params)
    valid=['','15','75','150','270']
    valid.include?(params["time1"]) && valid.include?(params["time2"]) && valid.include?(params["time3"]) && valid.include?(params["time4"])
  end

  def tex?(params)
    validTimes=['75','270']
    valid = ['','None','Only']
    test=[]
    4.times{|x| test << params["time#{x+1}"] if params["tex#{x+1}"] && valid.include?(params["tex#{x+1}"])}
    test.size == 0 || test.uniq == validTimes || (test.uniq.size == 1 && validTimes.include?(test.uniq[0]))
  end

  def reducer?(reducer)
    ["Sum","Max","Avg"].include?(reducer)
  end

  def checkparams(params)
      # If errors render index and show errors
    @errors << "Negative distance between start and stop." if negDist?(params[:start],params[:end])
    @errors << "Selected region larger than 50kb" unless lessThanLimit?(params[:start],params[:end])
    @errors << "Invalid chromosome specified" unless chrom?(params["chr"])
    @errors << "Invalid stress specified" unless stress?(params)
    @errors << "Invalid time specified" unless time?(params)
    @errors << "Invalid TEX treatment specified" unless tex?(params)
    @errors << "Invalid reducer specified" unless reducer?(params["reducer"])
  end
end
