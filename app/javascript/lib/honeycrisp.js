var incrementer = (function () {
    var i = {
        increment: function (input) {
            var max = parseInt($(input).attr('max'));
            var value = parseInt($(input).val());
            if (max != undefined) {
                if (value < max) {
                    $(input).val(value + 1);
                }
            } else {
                $(input).val(parseInt($(input).val()) + 1);
            }
        },
        decrement: function (input) {
            var min = parseInt($(input).attr('min'));
            var value = parseInt($(input).val());
            if (min != undefined) {
                if (value > min) {
                    $(input).val(value - 1);
                }
            } else {
                $(input).val(value - 1);
            }

        },
        init: function () {
            $('.incrementer').each(function (index, incrementer) {
                var addButton = $(incrementer).find('.incrementer__add');
                var subtractButton = $(incrementer).find('.incrementer__subtract');
                var input = $(incrementer).find('.text-input');

                $(addButton).click(function (e) {
                    i.increment(input);
                });

                $(subtractButton).click(function (e) {
                    i.decrement(input);
                });
            });
        }
    }
    return {
        init: i.init
    }
})();

var radioSelector = (function () {
    var rs = {
        init: function () {
            $('.radio-button').each(function (index, button) {
                if ($(this).find('input').is(':checked')) {
                    $(this).addClass('is-selected');
                }

                $(this).find('input').click(function (e) {
                    var allRadioButtons;
                    if ($(this).closest('.cfa-radio-button').length > 0) {
                        // FormBuilder V2
                        allRadioButtons = $(this).closest('.cfa-radio-button').siblings().children('.is-selected');
                    } else {
                        // FormBuilder V1 & GCF
                        allRadioButtons = $(this).closest('.radio-button').siblings();
                    }
                    allRadioButtons.removeClass('is-selected');
                    $(this).closest('.radio-button').addClass('is-selected');
                })
            })
        }
    }
    return {
        init: rs.init
    }
})();

var checkboxSelector = (function () {
    var cs = {
        init: function () {
            $('.checkbox').each(function (index, button) {
                if ($(this).find('input').is(':checked')) {
                    $(this).addClass('is-selected');
                }

                $(this).find('input').click(function (e) {
                    if ($(this).is(':checked')) {
                        $(this).closest('.checkbox').addClass('is-selected');
                    } else {
                        $(this).closest('.checkbox').removeClass('is-selected');
                    }
                })
            })
        }
    }
    return {
        init: cs.init
    }
})();

var followUpQuestion = (function () {
    var fUQ = {
        init: function () {
            $('.question-with-follow-up').each(function (index, question) {
                var self = this;

                // set initial state of follow-ups based on the page
                $(this).find('input').each(function (index, input) {
                    var $input = $(this);
                    var followUpSelector = $input.attr('data-follow-up');
                    if (followUpSelector) {
                        var selectors = followUpSelector.split(/\s+/);
                        selectors.forEach(function (selector) {
                            if (/^[a-zA-Z0-9_\-#\.]+$/.test(selector)) { // protects against XSS through DOM
                                if ($input.is(':checked')) {
                                    $(selector).find('input, select').attr('disabled', false);
                                    $(selector).show();
                                } else {
                                    if ($('[data-follow-up*="' + selector + '"]:checked').length === 0) {
                                        $(selector).find('input, select').attr('disabled', true);
                                        $(selector).hide();
                                    }
                                }
                            }
                        });
                    }
                });

                // add click listeners to initial question inputs
                $(self).find('> .question-with-follow-up__question input').click(function (e) {
                    fUQ.update($(self));
                });
            });
        },
        update: function ($container) {
            $container.find('> .question-with-follow-up__follow-up input, > .question-with-follow-up__follow-up select').attr('disabled', true);
            $container.find('> .question-with-follow-up__follow-up').hide();

            $container.find('.question-with-follow-up__question input').each(function (index, input) {
                // if any of the inputs with a data-follow-up is checked then show the follow-up
                if ($(input).is(':checked') && $(input).attr('data-follow-up') != null) {
                    var followUpSelector = $(this).attr('data-follow-up');
                    var selectors = followUpSelector.split(/\s+/);
                    selectors.forEach(function (selector) {
                        if (/^[a-zA-Z0-9_\-#\.]+$/.test(selector)) {
                            $(selector).show();
                            $(selector).find('input, select').attr('disabled', false);
                        }
                    });
                }
            });
        }
    }
    return {
        init: fUQ.init,
        update: fUQ.update
    }
})();

var revealer = (function () {
    var rv = {
        init: function () {
            $('.reveal').each(function (index, revealer) {
                var self = revealer;
                $(self).addClass('is-hiding-content');
                var revealButton = $(self).find('.reveal__button')
                revealButton.each(function (i, link) {
                    link.setAttribute('aria-expanded', false);
                    link.setAttribute('type', 'button');
                })
                revealButton.click(function (e) {
                    e.preventDefault();
                    $(self).toggleClass('is-hiding-content');

                    if (this.getAttribute('aria-expanded') === 'false') {
                        this.setAttribute('aria-expanded', 'true');
                    } else {
                        this.setAttribute('aria-expanded', 'false')
                    }
                });
            });
        }
    }
    return {
        init: rv.init
    }
})();

var immediateUpload = (function () {
    var uploader = function () {
        var $formInputs = $('input[type="file"][data-upload-immediately]');

        $formInputs.each(function (index, formInput) {
            let $formInput = $(formInput);
            var $form = $formInput.closest('form');
            let requiredSelectId = $formInput.data('requires-value-for');
            if (requiredSelectId) {
                let $select = $(`#${requiredSelectId}`);
                let handleSelectChange = function (event) {
                    let hasRequiredValue = $select.val() == '';
                    formInput.disabled = hasRequiredValue;
                    $form.toggleClass('file-selection-disabled', hasRequiredValue)
                };
                handleSelectChange();
                $select.change(handleSelectChange);
            }
            $form.find("button[type=submit]").hide();
            $form.find("input[type=submit]").hide();
            $form.find('label[for=' + formInput.id + ']').show();
            $formInput.addClass('file-upload__input');
        }).change(function (event) {
            $(this).closest('form').submit();
            var dataUploading = $formInputs.data("uploading");
            if (dataUploading) {
                $(this).replaceWith("<h2 class='text--no-top-margin'>" + dataUploading + "</h2>");
            }
        });
    };

    return {
        init: uploader
    }
})();

var inputGroupSelector = (function () {
    var igs = {
        init: function () {
            $('.text-input-group .text-input').each(function (index, input) {
                if ($(this).attr('autofocus')) {
                    $(this).parent().addClass('is-focused');
                }
                $(this).focusin(function () {
                    $(this).parent().addClass('is-focused');
                })

                $(this).focusout(function () {
                    $(this).parent().removeClass('is-focused');
                })

            })
        }
    }
    return {
        init: igs.init
    }
})();

var noneOfTheAbove = (function () {
    var noneOf = {
        init: function () {
            var $noneCheckbox = $('#none__checkbox');
            var $otherCheckboxes = $('input[type=checkbox]').not('#none__checkbox');

            // Uncheck None if another checkbox is checked
            $otherCheckboxes.click(function (e) {
                $noneCheckbox.prop('checked', false);
                $noneCheckbox.parent().removeClass('is-selected');
            });

            // Uncheck all others if None is checked
            $noneCheckbox.click(function (e) {
                $otherCheckboxes.prop('checked', false);
                $otherCheckboxes.parent().removeClass('is-selected');

                // If we just unchecked an <input> with a follow-up, let's reset the follow-up questions
                // so it hides properly.
                var $enclosingFollowUp = $noneCheckbox.closest('.question-with-follow-up');
                if ($enclosingFollowUp) {
                    followUpQuestion.update($enclosingFollowUp);
                }
            });

        }
    };
    return {
        init: noneOf.init
    }
})();

var showMore = (function () {
    return {
        init: function () {
            $('.show-more').each(function (index, showmore) {
                $(showmore).find('.show-more__button').click(function (e) {
                    e.preventDefault();
                    $(showmore).addClass('is-open');
                })
            });
        }
    }
})();

var accordion = (function () {
    var ac = {
        init: function () {
            $('.accordion').each(function (index, accordion) {
                var self = accordion;
                $(self).addClass('accordion--is-closed');
                $(self).find('.accordion__button').attr('aria-expanded', "false");
                $(self).find('.accordion__button').click(function (e) {
                    e.preventDefault();
                    $(self).toggleClass('accordion--is-closed');
                    if ($(self).find('.accordion__button').attr('aria-expanded') == "false") {
                        $(self).find('.accordion__button').attr('aria-expanded', "true");
                    } else {
                        $(self).find('.accordion__button').attr('aria-expanded', "false");
                    }
                });
            });
        }
    }
    return {
        init: ac.init
    }
})();

var selectBodyBottomMargin = (function () {
    return {
        init: function () {
            var $compactFooter = $('body').find('.main-footer__compact');

            if ($compactFooter) {
                $('body').css("margin-bottom", $compactFooter.css("height"));
            }
        }
    }
})();

var autoformatEventHandler = function (characterMap, maxDigits) {
    return function (_e) {
        var input = $(this);
        var unformattedValue = input.val()
            .replace(/[^\d]/g, "")
            .substring(0, maxDigits);
        var formattedStr = [];
        for (var i = 0; i < unformattedValue.length; i++) {
            var specialChar = characterMap[i];
            if (specialChar !== undefined) {
                formattedStr.push(specialChar);
            }
            formattedStr.push(unformattedValue.charAt(i));
        }
        input.val(formattedStr.join(""));
    }
};

function formatNumericInput(selector, characterMap, maxDigits) {
    var handler = autoformatEventHandler(characterMap, maxDigits);
    $(selector).each(function (_index, input) {
        handler.call(this, null); // format existing value on page load (not yet tested, need JS testing first)
        $(input).on('input', handler);
    });
}

var numericFormatters = {
    init: function () {
        formatNumericInput('.phone-input', {0: '(', 3: ') ', 6: '-'}, 10);
        formatNumericInput('.ssn-input', {3: '-', 5: '-'}, 9);
    }
};

var honeycrispInit = function () {
    incrementer.init();
    radioSelector.init();
    checkboxSelector.init();
    followUpQuestion.init();
    immediateUpload.init();
    revealer.init();
    inputGroupSelector.init();
    noneOfTheAbove.init();
    showMore.init();
    accordion.init();
    selectBodyBottomMargin.init();
    numericFormatters.init();
}

var Honeycrisp = function () {
    return {
        init: function () {
            $(document).ready(function () {
                honeycrispInit();
            });
        }
    }
}();

Honeycrisp.init();
