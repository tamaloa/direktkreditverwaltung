class MailTemplatesController < ApplicationController

  # GET /mail_templates/1/edit
  def edit
    @mail_template = MailTemplate.find(params[:id])
  end

  # PUT /mail_templates/1
  # PUT /mail_templates/1.json
  def update
    @mail_template = MailTemplate.find(params[:id])

    newsletter_file = params[:mail_template].delete(:newsletter)

    respond_to do |format|
      if @mail_template.update_attributes(mail_template_params) && @mail_template.update_newsletter_file(newsletter_file)
        format.html { redirect_to emails_url(year: @mail_template.year), notice: 'Mail template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mail_template.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def mail_template_params
    params.require(:mail_template).permit(:content, :footer, :subject)
  end
end
