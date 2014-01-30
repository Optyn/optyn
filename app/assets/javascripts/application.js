// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= jquery-migrate-1.2.1
//= require jquery-ui-1.9.2.custom.min
//= require bootstrap
//= require_directory ./stripe
//= require chosen-jquery
//= require bootstrap-datetimepicker
//= require jquery.zclip.min.js
//= require shCore.js
//= require shLegacy.js
//= require shBrushXml.js
//= require bootstrap-colorpicker
//= require jquery.colorbox
//= require_self
//= require_tree

$(document).ready(function () {
    if ($('.date-time-picker').length && $('.date-time-picker .error').length) {
        moveDatetimepickerErrorMessage();
    }

    if($('label.checkbox').length){
        fixCheckboxLabel();
    }

    var _prum = [['id', '52ea0de4abe53d2127000000'],
    ['mark', 'firstbyte', (new Date()).getTime()]];
    (function() {
        var s = document.getElementsByTagName('script')[0]
        , p = document.createElement('script');
        p.async = 'async';
        p.src = '//rum-static.pingdom.net/prum.min.js';
        s.parentNode.insertBefore(p, s);
    })();

});

function moveDatetimepickerErrorMessage() {
    var $errorMessage = $('.date-time-picker .error');
    var $errorMessageGrandParent = $errorMessage.parent().parent().parent();

    var $newErrorMesageContainer = $('<span />');
    $newErrorMesageContainer.attr({
        'class': 'field-with-errors'
    });
    $newErrorMesageContainer.append($errorMessage);
    $errorMessageGrandParent.append($newErrorMesageContainer);
}

function fixCheckboxLabel(){
    var $temp = $('<div />');
    $('label.checkbox').find('input[type=hidden]').each(function(index, element){
        $temp.append(element);
    });

    $('label.checkbox').before($temp.html());
}
