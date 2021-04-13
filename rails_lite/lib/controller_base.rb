require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    return @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'Dont double render' if @already_built_response
      
    @res.location = url
    @res.status = 302
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'Dont double render' if @already_built_response
    @res.content_type = content_type
    @res.write(content)

    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    #     Use controller and template names to construct paths to template files.
    controller_name = self.class.name.underscore
    path = "views/#{controller_name}/#{template_name}.html.erb"
    # Use File.read to read the template file.
    file = File.read(path)
    # Create a new ERB template from the contents.
    template = ERB.new(file)
    # Evaluate the ERB template, using binding to capture the controller's instance variables.
    content = template.result(binding)
    # Pass the result to #render_content with a content_type of text/html
    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

