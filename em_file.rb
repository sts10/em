Dir["./extensions/*.rb"].each {|file| require file }

class EmFile
    attr_accessor :em_file_location, :em_array, :html_text, :all_head_code, :all_body_top_code
    def initialize(em_file_location)
        @em_file_location = em_file_location
        self.em_array = []
    end
    def read_em_file
        file= File.new(em_file_location, "r")
        while (line = file.gets)
            self.em_array << line
        end
    end

    def make_models_array
        model_names = []

        model_files = Dir["./extensions/*.rb"]
        model_files.each do |model_path|
            basename = File.basename(model_path, ".*")
            model_name = camel_case(basename)
            model_names << model_name
        end

        model_names
    end

    def camel_case(str)
        str = str.gsub(/\_(.)/) {|e| e.upcase}.gsub("_","")
        str = str.slice(0,1).capitalize + str.slice(1..-1)
    end

    def filter_em
        model_names = self.make_models_array

        new_array = []
        self.em_array.each do |em_line|
            model_identity = false

            model_names.each do |model_name|
                if Object.const_get(model_name).identify(em_line)
                    model_identity = model_name 
                    break
                end
            end
            if model_identity != false
                new_array << Object.const_get(model_identity).new(em_line).present
            else
                new_array << em_line
            end
        end

        # replace the em_array           
        self.em_array = new_array
    end
    
    def em_array_to_html
        self.em_array.each do |em_line|
            em_line = Kramdown::Document.new(em_line, :input => "GFM", :coderay_line_numbers => nil, :smart_quotes => ["lsquo", "rsquo", "ldquo", "rdquo"]).to_html

            # replace smart quotes and other puncution with they HTML codes or dumb alternatives
            em_line = em_line.gsub("“", "&ldquo;").gsub("”", "&rdquo;").gsub("‘", "&lsquo;").gsub("’", "&rsquo;").gsub("–", "&mdash;").gsub('…', '...')
            em_line = em_line.gsub("&acirc;&#128;&#156;", '&ldquo;').gsub("&acirc;&#128;&#157;", '&rdquo;').gsub("&acirc;&#128;&#152;", "&lsquo;").gsub("&acirc;&#128;&#153;", "&rsquo;")

            if self.html_text 
                self.html_text = self.html_text + em_line
            else
                self.html_text = em_line
            end
        end
    end

    def gather_frontend_code
        model_names = self.make_models_array
        self.all_head_code = ""
        self.all_body_top_code = ""

        model_names.each do |model|
            # test if this model has a CLASS method called head_code
            if Object.const_get(model).methods.include? :head_code
                puts "Yes, #{Object.const_get(model)} has head_code!"
                self.all_head_code = self.all_head_code + Object.const_get(model).head_code
            end
            if Object.const_get(model).methods.include? :body_top_code
                puts "Yes, #{Object.const_get(model)} has body_top_code!"
                self.all_body_top_code = self.all_body_top_code + Object.const_get(model).body_top_code
            end
        end
    end



    def convert_and_print_to(print_location)
        self.read_em_file
        self.filter_em
        self.em_array_to_html
        self.gather_frontend_code

        puts "I'm printing to #{print_location}"
        puts "here's self.html_text"
        puts self.html_text


        template_doc= File.open("./templates/template.html.erb", "r")
        template = ERB.new(template_doc.read)

        File.open(print_location, "w") do |f|
            f.write(
                template.result(binding) # result is an ERB method. `binding` here means we're passing all local variables to the template. 
            )
            f.close
        end
    end
end

