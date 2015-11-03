require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts(form_letter)
  end
end

def clean_phone_number(phone_number)
  numbers_string = phone_number.gsub(/\D/, '')
  if numbers_string.length == 10 && numbers_string[0] != "1"
    numbers_string = numbers_string.insert(6,"-").insert(3,"-")
  elsif numbers_string.length == 11 && numbers_string[0] == "1"
    numbers_string[0] = ''
    numbers_string = numbers_string.insert(6,"-").insert(3,"-")
  else
    "Error: Invalid phone number"
  end 
end

def time_targetting(date_and_time)
  time = DateTime.strptime(date_and_time, '%m/%d/%y %H:%M')
  hour = time.hour
end

def day_of_week_targetting(date_and_time)
  time = DateTime.strptime(date_and_time, '%m/%d/%y %H:%M')
  day_of_week = time.wday
  case day_of_week
  when 0
    "Sunday"
  when 1
    "Monday"
  when 2
    "Tuesday"
  when 3
    "Wednesday"
  when 4
    "Thursday"
  when 5
    "Friday"
  when 6
    "Saturday"
  end
end

def time_frequency(time_hash)
  frequent_time = nil
  frequent_times = nil
  number_of_registrants = 0
  time_hash.each do |time, value|
    if number_of_registrants == value
      frequent_times ||= [frequent_time]
      frequent_times.push(time)
    elsif value > number_of_registrants
      frequent_time = time
      number_of_registrants = value
      frequent_times = nil
    end
  end

  if frequent_times
    puts "The most frequent times of registration were #{frequent_times.join(', ')}, each with #{number_of_registrants} regisrants."
  else
    puts "The most frequent time of registration was #{frequent_time}, with #{number_of_registrants} registrants."
  end
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)
hour_hash = Hash.new(0)
day_hash = Hash.new(0)

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])
  
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  #save_thank_you_letters(id,form_letter)

  #phone_number = clean_phone_number(row[:homephone])
  #phone_number = phone_number
  #puts "#{name} #{phone_number}"

  #reg_hour = time_targetting(row[:regdate])
  #hour_hash[reg_hour] += 1

  reg_day = day_of_week_targetting(row[:regdate])
  day_hash[reg_day] += 1
end

#time_frequency(hour_hash)
time_frequency(day_hash)

