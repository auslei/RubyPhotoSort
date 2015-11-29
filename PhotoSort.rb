# encoding: utf-8
require 'fileutils'
require 'EXIFR'

# put source and destination files here
sourceDir = "E:\\Anthony\\Pictures\\Masters"
destDir = "E:\\Photos"

#sort all the photos from one folder to another folder with logics
def sortOutFiles(sourceDir, destDir, i)	
	if Dir.exist?(sourceDir)
		Dir.foreach(sourceDir) {|filename|
			if(filename != "." && filename != "..")
				if File.directory?("#{sourceDir}\\#{filename}") 
					#puts "Directory: #{sourceDir}\\#{filename}"
					i = i + sortOutFiles("#{sourceDir}\\#{filename}", destDir, 0)					
				else
					#puts filename + ": " + File.mtime("#{sourceDir}\\#{filename}").to_s
					if isRightSize?("#{sourceDir}\\#{filename}")
						copyFileToDestination(destDir, "#{sourceDir}\\#{filename}")
					end
					i = i + 1
				end
			end
		}
	else
		puts "#{sourceDir} does not exist"
	end
	return i
end


#copy the right files to the right destications.
def copyFileToDestination(destFolder, filePath)
	puts filePath
	
	begin 
		date = EXIFR::JPEG.new(filePath).date_time 
		dateyear = date.year
		datemonth = date.strftime("%B")
	rescue
		puts "Not able to extract tag, using modified date instead"
		date = File.mtime(filePath)
		dateyear = date.year
		datemonth = date.strftime("%B")
	end
	
	#are the photos of the right size?
	if isRightSize?(filePath)
		if Dir.exist?(destFolder) 		
			unless File.exist?("#{destFolder}\\#{dateyear}")
				puts "Creating folder #{destFolder}\\#{dateyear}"
				Dir.mkdir("#{destFolder}\\#{dateyear}")
			end
			
			unless File.exist?("#{destFolder}\\#{dateyear}\\#{datemonth}")
				puts "Creating folder #{destFolder}\\#{dateyear}\\#{datemonth}"
				Dir.mkdir "#{destFolder}\\#{dateyear}\\#{datemonth}"
			end
			
			extn = File.extname(filePath)
			fname = File.basename(filePath, extn)
			newfilename = "#{fname}_#{date.to_i}.#{extn}"
			
			if File.exist?("#{destFolder}\\#{dateyear}\\#{datemonth}\\#{newfilename}") == false
				FileUtils.cp(filePath, "#{destFolder}\\#{dateyear}\\#{datemonth}\\#{newfilename}")
			end
		end
	end 
end

def isRightSize?(filePath)
	begin
		fileSize = File.size(filePath)/1024/1024
		if fileSize >= 1 
			return true
		else
			return false
		end
	rescue
		puts "#{filePath} is found but cannot be read"
	end
end

sortOutFiles(sourceDir, destDir, 0)
