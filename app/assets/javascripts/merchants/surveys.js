$(document).ready(function () {
    var merchantSurvey = new MerchantSurvey();
    merchantSurvey.initialize();
});

function MerchantSurvey() {
    var addQuestionPath = null;
    var loadQuestionsPath = null;
    var elementTypePreviousValue = null;

    this.initialize = function () {
        this.hookSelectSurvey();
        if ($('#new_survey_questions_content').length) {
            addQuestionPath = this.getAddQuestionPath();
            loadQuestionsPath = this.getLoadQuestionsPath();
            this.loadQuestions();
            this.hookNewQuestionModal();
            this.hookEditQuestionModal();
            this.hookAddQuestion();
            this.hookEditQuestion();
            this.hookSaveChanges();
            this.hookSurveyQuestionFormSubmission();
            this.hookValueAdd();
            this.hookValueRemove();
            this.toggleValues();
            this.assignSurveyState();
            this.hookDeleteQuestion();
            this.hideButtonsInLaunchedSurvey();
        }
    };

    //hook the modal for adding questions
    this.hookNewQuestionModal = function () {
        $('#new_survey_questions_content').modal({
            keyboard: false,
            show: false
        });
    };

    //hook the modal for adding questions
    this.hookEditQuestionModal = function () {
        $('#edit_survey_questions_content').modal({
            keyboard: false,
            show: false
        });
    };

    //Add a question to the survey
    this.hookAddQuestion = function () {
        var current = this;
        $('button.add_question_button').click(function (e) {

            $('#new_survey_questions_content .modal-footer').hide();

            $('#new_survey_questions_content').modal('show');
            jQuery.ajax({
                url: addQuestionPath,
                success: function (data) {
                    $('#new_survey_questions_content .modal-body').html(data);
                    $('#new_survey_questions_content  .values-container').hide();
                },
            });

            $('#new_survey_questions_content .modal-footer').show();

            elementTypePreviousValue = $('#survey_question_element_type').val();

        });
    };

    //Edit a question for the survey
    this.hookEditQuestion = function () {
        var current = this;
        var href = null;
        $('body').on('click', '.edit_question_link', function (e) {
            var href = $(this).attr('href');
            e.preventDefault();

            $('#edit_survey_questions_content .modal-footer').hide();

            $('#edit_survey_questions_content').modal('show');

            jQuery.ajax({
                url: href,
                success: function (data) {
                    $('#edit_survey_questions_content .modal-body').html(data);
                    var elementVal = $('#survey_question_element_type').val();
                    if (elementVal && (elementVal.match('text') || elementVal.match('textarea'))) {
                        $('#edit_survey_questions_content  .values-container').hide();
                    }
                    elementTypePreviousValue = $('#survey_question_element_type').val();
                }
            });

            $('#edit_survey_questions_content .modal-footer').show();



        });
    };


    //Observer for the save changes button click
    this.hookSaveChanges = function () {
        $('body').on('click', 'button.save_question_change', function () {
            $('#survey_question_form').submit();
        });

        $("#save_question_change").click(
            function(){ 
                $('#survey_question_form').submit();
            }
            );
    };

    //Form submission observer Add Question
    this.hookSurveyQuestionFormSubmission = function () {
        var current = this;
        $('body').on('submit', '#survey_question_form', function (event) {
            var $form = $('#survey_question_form');
            var $modalBody = $('#new_survey_questions_content .modal-body');
            event.preventDefault();
            $.ajax({
                url: $form.attr('action'),
                type: "POST",
                beforeSend: function () {
                    $form.find('#form_container').hide();
                    $form.find('#please_wait').show();
                },
                data: $('#survey_question_form').serializeArray(),
                success: function () {
                    $modalBody.html("<strong>Please Wait...</strong>");
                    if ($(".launch_survey").length == 0){
                        $(".preview_survey").after(' <input type="submit" value="Launch" title="Launch this survey" name="launch" class="btn btn-success submit_survey launch_survey ">');
                    }
                    else{
                        $(".launch_survey").show();
                    }
                    current.loadQuestions();
                    $('#new_survey_questions_content').modal('hide');
                    $('#edit_survey_questions_content').modal('hide');
                },
                error: function (request) {
                    $modalBody.html(request.responseText);
                }
            });
        });
    };

    // Populate the list of questions
    this.processQuestions = function (questions) {
        if (questions.length) {
            var tableHeader = '<table class="table table-hover table-striped">' +
            '<thead>' +
            '<tr>' +
            '<th>Element Type</th>' +
            '<th>Question</th>' +
            '<th>Position</th>' +
            '<th>Values</th>' +
            '<th>Actions</th>' +
            '</tr>' +
            '</thead>' +
            '<tbody>';

            var tableBody = "";

            var tableFooter = '</tbody>' +
            '</table>';

            $(questions).each(function (index, element) {
                tableBody += "<tr class='row-container'>" +
                "<td>" + element.element_type + "</td>" +
                "<td>" + element.label + "</td>" +
                "<td>" + element.position + "</td>" +
                "<td>" + element.values.join("<br />") + "</td>" +
                "<td>" + '<div class="btn-group"><a href="' + element.edit_path + '" class="edit_question_link btn btn-primary"><i class="icon-edit"></i></a>';
                if (element.delete_path == "")//dont show delete button if survey is launched
                {    
                    tableBody += "</div></td>";
                }
                else
                {
                    tableBody +='<a href="' + element.delete_path + '" class="delete_question_link btn btn-danger"><i class="icon-trash"></a>' + "</div></td>";
                }
                tableBody +="</tr>";
            });

            $('#questions_list').html(tableHeader + tableBody + tableFooter)
        } else {
            $('#questions_list').html("<strong>No Questions available</strong>");
        }
    };

    //Add the values to the survey options
    this.hookValueAdd = function () {
        $('body').on('click', '#add_value', function () {
            var $values = $('.values');
            var $clonedValue = $values.find('.value-container').first().clone();
            $clonedValue.find('input').val('');
            var $temp = $('<div />');
            $temp.append($clonedValue);
            $values.append($temp.html());
            $values.find('.value-container').find('input').last().val('');
        });
    };

    //Remove the values for the survey question
    this.hookValueRemove = function () {
        $('body').on('click', '.remove-value', function () {
            var $content = $('#new_survey_questions_content');
            $(this).parents('.value-container').first().remove();
        });
    };

    //Observer for loading the survey questions table
    this.loadQuestions = function () {
        var current = this;
        $.ajax({
            url: loadQuestionsPath,
            type: 'GET',
            success: function (questions) {
                current.processQuestions(questions);
            },
            error: function () {
                alert('Could not load the questions for your survey. Please refresh your page.');
            }
        })
    };

    //Fetch the url for adding a question
    this.getAddQuestionPath = function () {
        return $('#new_merchants_survey_survey_question_path').val();
    };

    //Fetch the url for loading the questions
    this.getLoadQuestionsPath = function () {
        return $('#questions_merchants_survey_path').val();
    };

    this.toggleValues = function () {
        $('body').on('change', '#survey_question_element_type', function () {
            var $values = $('.values-container .value-container');
            var $valuesContainer = $('.values-container');
            var thisVal = $(this).val();

            //check if text or textarea was selected then hide the values box
            if (thisVal.match('text') || thisVal.match('textarea')) {
                $valuesContainer.hide();

                //if anwerchoices were added then warn and confirm with user if they want to override their prev choice
                if (($values.length > 1) || ($values.length == 1 && $values.find('input').first().val().length)) {
                    var confirmation = confirm("You were trying to add answer choices to this question. " +
                        "You will loose those changes. " +
                        "Are you sure you want to go for it?");

                    if (confirmation) {//if the user confirms their choice then hide the added choices and delete the content
                        $valuesContainer.find('.value-container:not(:last)').remove()
                        $valuesContainer.find('.value-container input').val('');
                    } else {//if the user does not confirm keep the values and keep the users previous choices
                        $('#survey_question_element_type').val(elementTypePreviousValue);
                        $valuesContainer.show();
                    }
                }
            } else {//If answer choices were not added and choice was changes don't touch the values list
                $valuesContainer.show();
            }

            elementTypePreviousValue = thisVal;
        });
    };

    this.assignSurveyState = function () {
        $('.submit_survey').click(function (e) {
            var thisName = $(this).attr('name');
            if (thisName.match('launch')) {
                // alert(thisName);
                $('#survey_ready').val('1');
            } else if (thisName.match('draft')) {
                // alert(thisName);
                $('#survey_ready').val('0');
            }

            $('#choice').val(thisName);
        });
    };

    this.hookDeleteQuestion = function () {
        $('body').on('click', '.delete_question_link', function (event) {
            var $this = $(this);
            var href = $this.attr('href');
            event.preventDefault();

            if (confirm("Are you sure you want to you want to delete this question. The related answers if present will be deleted?")) {
                $.ajax({
                    url: href,
                    type: 'POST',
                    data: {
                        authenticity_token: jQuery("[name='authenticity_token']").val(),
                        _method: "delete"
                    },
                    beforeSend: function () {
                        $this.attr('href', 'javascript:void(0)');
                    },
                    success: function (data) {
                        $this.parents('.row-container').first().remove();
                        if ($(".table-striped tbody tr").length == 0){
                            $('.launch_survey').hide();
                        }
                    },
                    error: function () {
                        alert('Could not delete your question. Please try again');
                    }
                });
            }
        });
    };

    this.hookSelectSurvey= function () {
        $(document).on('submit','body.select_survey',function(data){
            $('#select_survey').attr("action", $(this).find(":selected").val());
        });
    };

    //hooks for hiding buttons not needed in launched emssages
    this.hideButtonsInLaunchedSurvey = function () {
    // $("#draft").hide();
        
    };

}