/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
  // Define changes to default configuration here.
  // For the complete reference:
  // http://docs.ckeditor.com/#!/api/CKEDITOR.config

  // The toolbar groups arrangement, optimized for two toolbar rows.

  config.toolbar = 'Custom';
  
  config.height = '170px';

  config.extraPlugins = 'simpleLink';
  config.pasteFromWordPromptCleanup = true;
  config.pasteFromWordRemoveFontStyles = true;
  config.forcePasteAsPlainText = true;
  config.ignoreEmptyParagraph = true;
  config.removeFormatAttributes = true;

  CKEDITOR.config.allowedContent = true;
  // config.toolbar_Full =  [['Styles', 'Bold', 'Italic', 'Underline', 'SpellChecker', 'Scayt', '-', 'NumberedList', 'BulletedList'],['Link', 'Unlink'], ['Undo', 'Redo', '-', 'SelectAll', 'linkbutton']];

   config.toolbar_Custom =
  [
  {
    name: 'styles',
    items : [ 'Font', 'FontSize' ]
  },
  {
    name: 'basicstyles',
    items : [ 'Bold','Italic','Underline', '-', 'TextColor']
  },
  {
    name: 'paragraph',
    items : ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock',
    'NumberedList','BulletedList','Outdent','Indent','Blockquote','-', 'RemoveFormat']
  },
  {
    name: 'links',
    items : [ 'Link', 'SimpleLink', 'Source' ]
  }
  ];


  // Remove some buttons, provided by the standard plugins, which we don't
  // need to have in the Standard(s) toolbar.

  // Se the most common block elements.
  config.format_tags = 'p;h1;h2;h3;pre';

  // Make dialogs simpler.
  config.removeDialogTabs = 'image:advanced;link:advanced';




  // Added to retain upload functionality
  // Define changes to default configuration here. For example:
  // config.language = 'fr';
  // config.uiColor = '#AADC6E';

  /* Filebrowser routes */
  // The location of an external file browser, that should be launched when "Browse Server" button is pressed.
  config.filebrowserBrowseUrl = "";

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Flash dialog.
  config.filebrowserFlashBrowseUrl = "/ckeditor/attachment_files";

  // The location of a script that handles file uploads in the Flash dialog.
  config.filebrowserFlashUploadUrl = "/ckeditor/attachment_files";

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Link tab of Image dialog.
  config.filebrowserImageBrowseLinkUrl = "/ckeditor/pictures";

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Image dialog.
  config.filebrowserImageBrowseUrl = "/ckeditor/pictures";

  // The location of a script that handles file uploads in the Image dialog.
  config.filebrowserImageUploadUrl = "/ckeditor/pictures";

  // The location of a script that handles file uploads.
  config.filebrowserUploadUrl = "/ckeditor/attachment_files";

  // Rails CSRF token
  config.filebrowserParams = function(){
    var csrf_token, csrf_param, meta,
    metas = document.getElementsByTagName('meta'),
    params = new Object();

    for ( var i = 0 ; i < metas.length ; i++ ){
      meta = metas[i];

      switch(meta.name) {
        case "csrf-token":
          csrf_token = meta.content;
          break;
        case "csrf-param":
          csrf_param = meta.content;
          break;
        default:
          continue;
      }
    }

    if (csrf_param !== undefined && csrf_token !== undefined) {
      params[csrf_param] = csrf_token;
    }

    return params;
  };

  config.addQueryString = function( url, params ){
    var queryString = [];

    if ( !params ) {
      return url;
    } else {
      for ( var i in params )
        queryString.push( i + "=" + encodeURIComponent( params[ i ] ) );
    }

    return url + ( ( url.indexOf( "?" ) != -1 ) ? "&" : "?" ) + queryString.join( "&" );
  };

  // Integrate Rails CSRF token into file upload dialogs (link, image, attachment and flash)
  CKEDITOR.on( 'dialogDefinition', function( ev ){
    // Take the dialog name and its definition from the event data.
    var dialogName = ev.data.name;
    var dialogDefinition = ev.data.definition;
    var content, upload;
    if ( dialogName == 'link' )
    {
      // Remove the 'Target' and 'Advanced' tabs from the 'Link' dialog.
      dialogDefinition.removeContents( 'target' );
      dialogDefinition.removeContents( 'advanced' );
      dialogDefinition.removeContents( 'upload' );

      // Get a reference to the 'Link Info' tab.
      var infoTab = dialogDefinition.getContents( 'info' );

      // Remove unnecessary widgets from the 'Link Info' tab.
      infoTab.remove( 'linkType');
      infoTab.remove( 'protocol');
      infoTab.remove( 'filebrowser');
    }
    if (CKEDITOR.tools.indexOf(['link', 'image', 'attachment', 'flash'], dialogName) > -1) {
      content = (dialogDefinition.getContents('Upload') || dialogDefinition.getContents('upload'));
      upload = (content == null ? null : content.get('upload'));

      if (upload && upload.filebrowser && upload.filebrowser['params'] === undefined) {
        upload.filebrowser['params'] = config.filebrowserParams();
        upload.action = config.addQueryString(upload.action, upload.filebrowser['params']);
      }
    }
  });
};
