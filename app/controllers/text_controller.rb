class TextController < ApplicationController
  require 'rubygems'
  require 'twilio-ruby'
  before_filter :require_user

  def index
    @value = ''
  end

  def create
    @invalid_num = Array[]
    if params[:commit] == 'Send To All!'
      send_to_all
    else
      num = params[:number].to_s.delete! '[\"]'
      mult_nums = num.split(', ')
      num_texts = mult_nums.length

      mult_nums.each do |val|
        if digit?(val)
          send_text(val)
        else
          a_num = find_number(val)
          if !a_num.nil?
            send_text(a_num)
          else
            @invalid_num << val
          end
        end
      end
    end

    handle_flash_notices(num, num_texts)
    render('index')
  end

  def handle_flash_notices(num, num_texts)
    if @invalid_num.length != 0
      if @invalid_num[0] == 'No Message'
        flash[:notice] = 'Message Required'
        @value = num
      else
        inv_num = @invalid_num.to_s.delete! '\"'
        flash[:notice] = "The contact(s) #{inv_num} are invalid,
                          others sent successfully"
        inv_num.delete! '[]'
        @value = inv_num
      end
    else
      unless num_texts.nil?
        if num_texts > 1
          flash[:notice] = 'Messages sent successfully.'
        else
          flash[:notice] = 'Message sent successfully.'
        end
      end
    end
  end

  def send_to_all
    students = Student.all
    students.each do |student|
    send_text(student.Phone_Number)
    end
  end

  def send_text(number)
    if params[:message] == ['']
      @invalid_num << 'No Message'
    elsif number.match(/\b\d{10}\b/)
      number = '+1' + number
      account_sid = 'ACc3ff9be899397461c075ffcf9e70f35a'
      auth_token = '48f209948887f585f820760a89915194'
      @client = Twilio::REST::Client.new account_sid, auth_token
      message = @client.account.messages.create(body: params[:message],
                                                to: number,
                                                from: '+16412434422')
      puts message.sid
    else
      @invalid_num << number
    end
  end

  # Determines whether or not the first digit of the given string is
  # a digit.
  def digit?(value)
    value[0].match(/\d/)
  end

  # Finds the number of a student or parent given their name.
  # Returns nil if a number is not found.
  def find_number(name)
    a_name = Student.find_by_Student_Name(name)
    return a_name.Phone_Number unless a_name.nil?

    a_name = Student.find_by_Parent_Name(name)
    return a_name.Phone_Number unless a_name.nil?
  end
end
