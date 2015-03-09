class StaticPagesController < ApplicationController
  def help
  end

  def resources
  end

  def contact
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
        flash[:error] = 'Sorry, our system classified this message as spam. Please try changing the text and send it again.'
        render :contact
      end
    rescue ScriptError
      flash[:error] = 'Sorry, our system classified this message as spam. Please try changing the text and send it again.'
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
