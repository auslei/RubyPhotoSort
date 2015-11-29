# encoding: utf-8
require 'fileutils'
require 'EXIFR'

sourceDir = "E:\\Anthony\\Programming\\Ruby"
destDir = "E:"

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
	fileSize = File.size(filePath)/1024/1024
	if fileSize >= 1 
		return true
	else
		return false
	end
end

puts sortOutFiles("F:\\temp", "E:\\Picasa", 0)
