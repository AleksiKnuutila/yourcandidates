class StaticPagesController < ApplicationController
  def help
  end

  def resources
  end

  def contact
    @contact_form = ContactForm.new
  end

  def contact_policy
    @contact_form = ContactForm.new
  end

  def contact_send
    begin
      @contact_form = ContactForm.new(:name => params[:InputName], :email => params[:InputEmail], :message => params[:InputMessage])
      @contact_form.request = request
      if @contact_form.deliver
        flash.now[:notice] = 'Thank you for your message!'
        render :contact
      else
        flash[:error] = 'Sorry, our system returned an error. Please try changing the text and send it again.'
        render :contact
      end
    rescue ScriptError
      flash[:error] = 'Sorry, our system classified this message as spam. Please try changing the text and send it again.'
    end
  end

  def contact_send_p
    message = "#{params[:policytype]}, #{params[:InputParty]}"
    pols = ['InputPol1', 'InputPol2', 'InputPol3', 'InputPol4', 'InputPol5', 'InputPol6' ] 
    for pol i pols
      message += " #{pol}: #{params[pol]}"
    end
    begin
      @contact_form = ContactForm.new(:name => params[:InputName], :email => params[:InputEmail], :message => message)
      @contact_form.request = request
      if @contact_form.deliver
        flash.now[:notice] = 'We have received your input, and will try to get back to you within a day.'
        render :contact_policy
      else
        flash[:error] = 'Sorry, our system returned an error. Please try changing the text and send it again.'
        render :contact_policy
      end
#    rescue ScriptError
#      flash[:error] = 'Sorry, our system classified this message as spam. Please try changing the text and send it again.'
    end
  end


  def copyright
  end

  def privacy
  end

  def linking
  end

  def about
  end
end
