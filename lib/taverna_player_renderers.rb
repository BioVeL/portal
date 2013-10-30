
# These methods are the default renderer callbacks that Taverna Player uses.
# If you customize (or add to) the methods in this file you must register them
# in the Taverna Player initializer. These methods will not override the
# defaults automatically.
#
# Each method MUST accept two parameters:
#  * The first (content) is what will be rendered. In the case of a text/*
#    type output this will be the actual text. In the case of anything else
#    this will be a path to the object to be linked to.
#  * The second (type) is the MIME type of the output as a string. This allows
#    a single method to handle multiple types or sub-types if needed.

def inline_pdf(content, type)
  "If you do not see the PDF document displayed in the browser below, "\
  "please download it (using the button above) and load it into a PDF "\
  "reader application on your local machine.<br/>" +
    tag(:iframe, :src => content, :class => "inline_pdf")
end

def workflow_error(content, type)
  "This output contains an error message. " +
    link_to("View error", content, :class => "link_img")
end
