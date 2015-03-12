class GenomeannotationsController < ApplicationController
require 'csv'

  def new
  end

  def create
    @annotation = Genomeannotation.new(annotation_params)
    if @annotation.save
      redirect_to @annotation
    else
      render 'new'
    end
  end

  def upload
    @records=[]
    @errors=[]
    if params[:annot_file]
      records=gtfparse(params[:annot_file],params[:author])
      records.each do |rec|
        test=Genomeannotation.new(rec)
        if test.invalid?
          @errors = test.errors
          @problem = rec.to_s
          render 'upload'
          break
        else
          @records << test
        end
      end
      unless @errors.any?
        @msg = "Success!"
        @records.each do |record|
          record.save
        end
      end
    end
  end


  def show
    @annotation = Annotation.find(params[:id])
  end



  def index
    params[:start]=params[:start].to_i
    params[:end]=params[:end].to_i
    puts(params)
    @errors = []; @limit = 50000
    # If parameters, do things else do nothing
    if (params[:start] && params[:end] && params[:chr])
      # If errors render index and show errors
      @errors << "Negative distance between start and stop." if negDist?(params[:start],params[:end])
      @errors << "Selected region larger than 50kb" unless lessThanLimit?(params[:start],params[:end])
      @errors << "Invalid chromosome specified" unless chrom?(params["chr"])
      @errors << "Invalid stress specified" unless stress?(params)
      @errors << "Invalid time specified" unless time?(params)
      @errors << "Invalid TEX treatment specified" unless tex?(params)
      @errors << "Invalid reducer specified" unless reducer?(params["reducer"])
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
              puts("Condition: #{@cond[i]}")
              @coverages = Coverage.search(annotation_render,@cond[i],i)
              #puts(@coverages.to_json)
              #params[:reducer] should be one of sum,avg,max
              @plus,@minus=@coverages.map{|x|x.as_json}.group_by{|x|x["strand"]}.values

              @plus=eval("cov_#{params[:reducer]}(@plus.group_by{|x|x['base']})")

              @minus=eval("cov_#{params[:reducer]}(@minus.group_by{|x|x['base']})")

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
    params.require(:genomeannotation).permit(:name,:author,:chr,:feature,:start_site,:stop_site,:strand,:technique,:journal,:date);
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

  def gtfparse(infile,author)
    records=[]
    contents=infile.read.split("\n")
    y,m,d=Time.now.to_s.split[0].split("-")
    contents.each do |line|
      unless line[0]=="#" || line.size < 5
        line=line.split("\t")
        line[0] = "Chrom" if line[0].include?("NC_003030") || line[0].upcase.include?("CHR")
        line[0] = "pSol1" if line[0].include?("NC_001988") || line[0].upcase.include?("PSOL")
        line[2]=line[2].upcase if line[2].upcase.include?("RBS") || line[2].upcase.include?("TSS") 
        line[2]="Hairpin" if line[2].upcase.include?("RIT") || line[2].upcase.include?("TERM")
        line[2]="ORF" if line[2].upcase.include?("CDS") || line[2].upcase.include?("PROT") || line[2].upcase.include?("ORF")
        line[2]="Transcript" if line[2].upcase.include?("MRNA") || line[2].upcase.include?("TRANS")
        line[2]="Promoter" if line[2].upcase.include?("PROM")
        line[2]="Factor" if line[2].upcase.include?("FACT") || line[2].upcase.include?("REPRES") || line[2].upcase.include?("OPERAT")
        optFields=line[-1].gsub(/"/,'').gsub(/'/,'').split
        i=optFields.index("ID")
        name = optFields[i+1].chomp(";")
        optFields.delete_at(i)
        optFields.delete_at(i)
        extra=optFields.map{|x|x.chomp(";")}.join(" ")
        record = {"chr"=>line[0],"technique"=>line[1],"feature"=>line[2],"start_site"=>line[3].to_i,"stop_site"=>line[4].to_i,"author"=>author,"strand"=>line[6],"date(1i)"=>y,"date(2i)"=>m,"date(3i)"=>d,"name"=>name,"extra"=>extra}
        records << record
      end
    end
    records
  end


end
