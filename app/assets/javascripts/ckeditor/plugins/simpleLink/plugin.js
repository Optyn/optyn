// Register a new CKEditor plugin.
// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.resourceManager.html#add
CKEDITOR.plugins.add( 'simpleLink',
{
	// The plugin initialization logic goes inside this method.
	// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.pluginDefinition.html#init
	init: function( editor )
	{
		// Create an editor command that stores the dialog initialization command.
		// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.command.html
		// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dialogCommand.html
		editor.addCommand( 'simpleLinkDialog', new CKEDITOR.dialogCommand( 'simpleLinkDialog' ) );
 
		// Create a toolbar button that executes the plugin command defined above.
		// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.ui.html#addButton
		editor.ui.addButton( 'SimpleLink',
		{
			// Toolbar button tooltip.
			label: 'Insert a Button Link',
			// Reference to the plugin command name.
			command: 'simpleLinkDialog',
			// Button's icon file path.
			icon: this.path + 'images/icon.png'
		} );


		editor.on( 'doubleclick', function( evt ) {
      var element = CKEDITOR.plugins.link.getSelectedLink( editor ) || evt.data.element;
      if ( !element.isReadOnly() ) {
        if (element.is('a') && element.hasClass('ss-button-link')){
          evt.data.dialog = 'simpleLinkDialog'
					var selection = editor.getSelection();
					selection.selectElement(element);
          //return false; //Stop the doubleclick propagation
        }
      }
    } );
 
		// Add a new dialog window definition containing all UI elements and listeners.
		// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dialog.html#.add
		// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dialog.dialogDefinition.html
		CKEDITOR.dialog.add( 'simpleLinkDialog', function( editor )
		{
			return {
				// Basic properties of the dialog window: title, minimum size.
				// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dialog.dialogDefinition.html
				title : 'Button Link',
				minWidth : 400,
				minHeight : 200,
				// Dialog window contents.
				// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dialog.definition.content.html
				contents :
				[
					{
						// Definition of the Settings dialog window tab (page) with its id, label and contents.
						// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dialog.contentDefinition.html
						id : 'general',
						label : 'Settings',
						elements :
						[
							// Dialog window UI element: HTML code field.
							// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.ui.dialog.html.html
							{
								type : 'html',
								// HTML code to be shown inside the field.
								// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.ui.dialog.html.html#constructor
								html : 'This dialog window lets you create button links for the content.'
							},
							// Dialog window UI element: a textarea field for the link text.
							// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.ui.dialog.textarea.html
							{
								type : 'text',
								id : 'contents',
								// Text that labels the field.
								// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.ui.dialog.labeledElement.html#constructor
								label : 'Button Caption',
								// Validation checking whether the field is not empty.
								validate : CKEDITOR.dialog.validate.notEmpty( 'The Button Caption field cannot be empty.' ),
								// This field is required.
								required : true,
								setup : function( element )
								{
									this.setValue( element.getText() );
								},
								// Function to be run when the commitContent method of the parent dialog window is called.
								// Get the value of this field and save it in the data object attribute.
								// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dom.element.html#getValue
								commit : function( data )
								{
									data.contents = this.getValue();
								}
							},
							// Dialog window UI element: a text input field for the link URL.
							// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.ui.dialog.textInput.html
							{
								type : 'text',
								id : 'url',
								label : 'URL',
								validate : CKEDITOR.dialog.validate.notEmpty( 'The link must have a URL.' ),
								required : true,
								setup : function( element )
								{
									this.setValue( element.getAttribute('href') );
								},
								commit : function( data )
								{
									data.url = this.getValue();
								}
							}
						]
					}
				],
				onShow : function()
				{
					var selection = editor.getSelection();
				  var selectedElement = selection.getStartElement();
					// Get the element selected in the editor.
					// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.editor.html#getSelection
					// var sel = editor.getSelection(),
					// Assigning the element in which the selection starts to a variable.
					// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dom.selection.html#getStartElement
						// element = sel.getStartElement();
					
					// Get the <abbr> element closest to the selection.
					// if ( selectedElement )
					// 	element = element.getAscendant( 'a', true );
					
					// Create a new <abbr> element if it does not exist.
					// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dom.document.html#createElement
					// For a new <abbr> element set the insertMode flag to true.
					if ( !selectedElement || selectedElement.getName() != 'a' || selectedElement.data( 'cke-realelement' ) )
					{
						selectedElement = editor.document.createElement( 'a' );
						selectedElement.appendHtml(selection.getSelectedText());
						this.insertMode = true;
					}
					// If an <abbr> element already exists, set the insertMode flag to false.
					else
						this.insertMode = false;
					
					// Store the reference to the <abbr> element in a variable.
					this.element = selectedElement;
					
					// Invoke the setup functions of the element.
					this.setupContent( this.element );
				},
				onOk : function()
				{
					// Create a link element and an object that will store the data entered in the dialog window.
					// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dom.document.html#createElement
					var dialog = this,
						data = {},
						link = editor.document.createElement( 'a' );
					// Populate the data object with data entered in the dialog window.
					// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dialog.html#commitContent
					this.commitContent( data );

					// Set the URL (href attribute) of the link element.
					// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dom.element.html#setAttribute
					var url = data.url
					if(!url.match(/^https?:\/\//)){
						url = "http://" + url;
					}

					link.setAttribute( 'href',  url);

					// In case the "newPage" checkbox was checked, set target=_blank for the link element.
					if ( data.newPage )
						link.setAttribute( 'target', '_blank' );
					link.setAttribute( 'class', 'ss-button-link' );
					link.setAttribute("style", OP.ckeditorButton.getStyle());

					// Set the style selected for the link, if applied.
					// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dom.element.html#setStyle
					// switch( data.style )
					// {
					// 	case 'b' :
					// 		link.setStyle( 'font-weight', 'bold' );
					// 	break;
					// 	case 'u' :
					// 		link.setStyle( 'text-decoration', 'underline' );
					// 	break;
					// 	case 'i' :
					// 		link.setStyle( 'font-style', 'italic' );
					// 	break;
					// }

					// Insert the Displayed Text entered in the dialog window into the link element.
					// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.dom.element.html#setHtml
					link.setHtml( data.contents );

					// Insert the link element into the current cursor position in the editor.
					// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.editor.html#insertElement
					editor.insertElement( link );
				}
			};
		} );
	}
} );