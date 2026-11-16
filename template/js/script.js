$(document).ready(function(){

    var lazyLoadInstance = new LazyLoad();

    var options = {
        format: "YYYY-MM-DD",
        locale: "pt",
        useCurrent: false,
        icons: {
            time: "fa fa-clock-o",
            date: "fa fa-calendar",
            up: "fa fa-arrow-up",
            down: "fa fa-arrow-down",
            previous: 'fa fa-chevron-left',
            next: 'fa fa-chevron-right',
        },
    };

    $('input[data-datepicker]').datetimepicker(options);

    if (Modernizr.mq('only screen and (max-width: 991px)')) {
        var headerHeight = $('header').offset().top + $('header').outerHeight(true);
    } else {
        var headerHeight = $('header').next().offset().top;
    }
    document.documentElement.style.setProperty('--header-height', ($('header').outerHeight() + $('.store-notice').outerHeight()));

    $(window).on('scroll', function () {
        if ($(window).scrollTop() > headerHeight) {
            $('nav.fixed-header').addClass('fixed');
            $('.fixed-header #nav-spacer').removeClass('hidden');

            if ($('.navbar-collapse').hasClass('in') && $('body').hasClass('fixed-header')) {
                $('body').addClass('fixed-header-open');
            }
        } else {
            $('.fixed-header #nav-spacer').addClass('hidden');
            $('nav.fixed-header').removeClass('fixed');
        }
    });

    $('.navbar button[data-target="#navbar-collapse"]').on('click', function () {
        var resize_element = $('.priority-nav');
        var duplicate_nav = resize_element.clone();

        if ($('.navbar').hasClass('fixed')){
            $('body.fixed-header').toggleClass('fixed-header-open');

            if (Modernizr.mq('only screen and (max-width: 991px)')) {
                $('.navigation-nav').toggleClass('col-md-9');
                $('.categories-nav').toggleClass('col-md-3');
            }

            resize_element.remove();
            $('header nav.navbar .navbar-collapse .collapse-content > .container > .row, header nav.navbar .navbar-collapse .collapse-content > .container-fluid > .row').prepend(duplicate_nav);

            if (!$('.navbar-collapse').hasClass('in')) {
                $('.dropdown-menu-wrapper .dropdown-menu > li').appendTo('.priority-nav .nav');
                $('.dropdown-menu-wrapper').remove();
            } else {
                $('body.fixed-header').removeClass('fixed-header-open');
                setTimeout(function(){
                    priority_nav();
                }, 1500);
            }
        }
    });

    if (typeof instagram_url !== 'undefined' && instagram_url) {
        var ig_username = instagram_url.replace(/^https?:\/\/[^\/]+\//, '').replace('/','');

        $.ajax({
            method: 'GET',
            cache: true,
            url: 'https://'+ location.host +'/instagram_feed/?store_alias=' + instagram_url,
            dataType: 'json'
        }).done(function(data) {
            if(typeof data.ig_data !== 'undefined') {
                var ig_posts_to_show = data.ig_data.media.length >= 10 ? 10 : 5;
                $('.instagram-block').append('<ul></ul>');

                $.each( data.ig_data.media, function( key, val ) {
                    if (key < ig_posts_to_show) {
                        var thumbnail = val.media_type == 'VIDEO' ? val.thumbnail_url : val.media_url;
                        $('.instagram-block > ul').append('<li><a href="'+val.permalink+'" target="_blank"><div><div style="background-image:url('+thumbnail+');"></div></div><span class="intagram-hover"><span class="instagram-logo"><i class="fab fa-instagram"></i></span><span class="instagram-likes">'+helper_icon_render('heart')+' '+val.like_count+'</span><span class="instagram-comments">'+helper_icon_render('comment')+' '+val.comments_count+'</span></span></a></li>');
                    }
                });
            }
            if ($('body').hasClass('feather')) {
                feather.replace();
            }
            lazyLoadInstance.update();
        });
    }

    function priority_nav() {
        var navigation = priorityNav.init({
            mainNavWrapper: ".navbar .navigation-nav",
            navDropdownLabel: helper_icon_render('bars', 'fa-sm'),
            navDropdownClassName: "dropdown-menu",
            turnOffPoint: 992,
            offsetPixels: 20
        });
    }

    priority_nav();

    // Only initialize zoom if the main product image is not a video
    var api = null;
    if ($('.easyzoom').length > 0 && $('.current-product-image video').length === 0) {
        var $easyzoom = $('.easyzoom').easyZoom({
            loadingNotice: lang.storefront.script.loading.text
        });
        api = $easyzoom.filter('.easyzoom').data('easyZoom');
    }

    $('.product-thumbs').on('click', 'a', function(e) {
        var $this = $(this);
        var thumb_href = $this.attr('data-standard');

        if(product.options.length > 0 && theme_options.trigger_thumbnail_option == 'show') {
            for (var i = 0; i < product.options.length; i++){
                if(product.options[i].image != null){
                    if(product.options[i].image.full == thumb_href) {
                        update_product_select(thumb_href);
                    } else {
                        api = change_product_image(api, $this);
                    }
                }
            }
        } else {
            api = change_product_image(api, $this);
        }

        e.preventDefault();
    });

    $('[data-toggle=tooltip]').tooltip();

    $('.nav-categories').find('.nav-sub-subcategories.in').closest('.nav-subcategories').addClass('in').prev('a').attr('aria-expanded', 'true').closest('li').addClass('active');

    //Cart / Shopkit functions

    check_shipping($('input[name="pagamento"]:checked'));

    $(document).on('change', 'input[name="pagamento"]', function() {
        check_shipping($(this));
    });

    $('form').submit(function() {
        $('body').css({ 'cursor': 'wait' });
        $(this).find('input[type=submit], button').prop('disabled', true);
    });

    $(document).on('init_app_shipping_info', function(){
		if (Modernizr.mq('only screen and (max-width: 991px)')) {
			$('body.page-cart .order-resume').insertAfter('.table-cart-products');
		}
	});

    $(window).resize(function() {
        if (Modernizr.mq('only screen and (max-width: 991px)')) {
            if (typeof $('body.page-cart form .table-cart-products').next('.order-resume')[0] === 'undefined') {
			    $('body.page-cart .order-resume').insertAfter('.table-cart-products');
            }
		} else {
			$('body.page-cart .order-resume').prependTo($('.order-resume-container'));
		}

        if ($('.table-responsive, .product-thumbs').length) {
            $('.table-responsive, .product-thumbs').each(function() {
                var _this = $(this);
                if (_this.hasScrollBar()) {
                    _this.addClass('has-mask');
                } else {
                    _this.removeClass('has-mask');
                }
            });
        }
    }).resize();

    $('.table-responsive.has-mask, .product-thumbs.has-mask').scroll(function() {
        var _this = $(this);
        var scroll_position = _this.scrollLeft();

        if (scroll_position > 0) {
            _this.addClass('mask-hidden');
        } else {
            _this.removeClass('mask-hidden');
        }
    });

    //Event on change
    $(document).on('change', '.select-product-options', function() {
        product_options(product);
    });

    //price on request button
    $('a.price-on-request').on('click', function() {

        var options = " - ";

        $('select.select-product-options').each(function(index, el) {
            options = options + $(this).children('option:selected').data('title') + " / ";
        });

        $(this).prop('href', $(this).prop('href') + options.slice(0, -3) + '#contact-form');
    });

    //Billing / Delivery data
    $(document).on('change', '#billing_info_same_delivery', function(event) {
        var _this = $(this);
        var target = _this.data('target');
        $(target).toggleClass('hidden');
    });

    $(document).on('blur', 'input[name$=zip_code]', function(e) {
        set_country_by_postal_code($(this));
    });

    $('.payment-methods .list-radio-block.list-group-item-active').find('select#pick_up_location').prop('required', true);

    $('.intl-validate').intlTelInput({
        initialCountry: 'pt',
        preferredCountries: ['pt','es','fr','ch','br','gb','de','lu','be','it','us'],
        utilsScript: 'https://cdn.shopk.it/js/intl-tel-input-17.0.8/build/js/utils.js'
    });

    $(document).on('keyup blur focus', '.intl-validate', function(event) {
        var _this = $(this);
        var e164 = event.type == 'focusout' ? true : false;
        validate_phone_intl_input(_this, e164);
    });

    $(document).on('change', '#delivery_country, #billing_country', function(event) {
        var _this = $(this);
        var type = _this.attr('id').split('_')[0];
        var phone_input = $('#'+ type +'_phone');
        var country = _this.find('option:selected').attr('value');

        if (country == 'PTA' || country == 'PTM') {
            country = 'PRT';
        }

        if (!phone_input.val()) {
            phone_input.intlTelInput('setCountry', getKeyByValue(countries_alpha_2, country));
        }
    });

    $('.product-description table, .product-tabs-content table, .product-tabs table').addClass('table').addClass('table-bordered').addClass('table-product-content');
    $('.product-description table, .product-tabs-content table, .product-tabs table').wrap('<div class="table-responsive"></div>');

    $('.panel-collapse.in').siblings('.panel-heading').addClass('active');

    $('.panel-collapse').on('show.bs.collapse', function () {
        $(this).siblings('.panel-heading').addClass('active');
    });

    $('.panel-collapse').on('hide.bs.collapse', function () {
        $(this).siblings('.panel-heading').removeClass('active');
    });

    //Related products
    if ($('[data-load="related-products"]').length) {
        $('[data-load="related-products"]').each(function() {
            var _this = $(this);
            var href = new URL(_this.attr('data-href'));

            href.searchParams.set('products', _this.attr('data-products'));
            href.searchParams.set('num_products', _this.attr('data-num-products'));
            href.searchParams.set('products_per_row', _this.attr('data-products-per-row'));
            href.searchParams.set('css_class_wrapper', _this.attr('data-css-class-wrapper'));
            href.searchParams.set('type', _this.attr('data-type'));

            $.ajax({
                method: 'GET',
                cache: true,
                url: href.toString(),
                dataType: 'html'
            }).done(function(data) {
                if (data) {
                    _this.find('.related-products-placement').html(data);
                    _this.removeClass('hidden');
                    if ($('body').hasClass('feather')) {
                        feather.replace();
                    }
                    lazyLoadInstance.update();
                }
            });
        });
    }

    $(document).on('change', '.extra-options [data-target]', function(event) {
        var _this = $(this);
        var target = _this.data('target');
        var is_checked = _this.is(':checked');
        var is_required = _this.is(':required');
        var toggle_color_option_label = !(is_checked && $('[name="' + target + '"]').find('input:checked').length);
        $('[name="' + target + '"]').toggleClass('hidden', !is_checked).prop('disabled', !is_checked).prop('required', is_required);

        if ($('[name="' + target + '"]').hasClass('list-colors')) {
            $('.extra-option-option-label', _this.parents('.extra-option')).toggleClass('hidden', toggle_color_option_label);
        }
    });

    (function () {
        $('.home-products .products').each(function(index, el) {
            var _this = $(this);

            if (_this.is(':visible')) {
                home_load_more(_this, lazyLoadInstance);
            }
        });
    })();

    $(document).on('click', '.home-products li a', function(e) {
        var _this = $(this);
        var target = _this.attr('href');
        var target_container = _this.parents('.home-products').find(target).children('.products');

        if(!$(target_container).hasClass('loaded')){
            home_load_more(target_container, lazyLoadInstance);
        }
    });

    $('.clean-filter').on('click', function(e) {
        e.preventDefault();
        var params = get_url_params();
        var params_keys = Object.keys(params).filter(function(index) {
            return index.indexOf('filter_') > -1 || index.indexOf('filter_price_') > -1 ? index : null;
        });
        for (var i = 0; i < params_keys.length; i++) {
            delete params[params_keys[i]];

            if (i == params_keys.length - 1) {
                location.href = generate_url(params);
            }
        }
    });

    (function () {
        var url_params_keys = Object.keys(get_url_params());
        if (Modernizr.mq('(min-width: 992px)')) {
            if (url_params_keys.indexOf('filter_price_min') > -1 || url_params_keys.indexOf('filter_price_max') > -1) {
                $('.filters .list-group-item [data-target="#price-range"]').trigger('click');
            }
            for (var i = 0; i < url_params_keys.length; i++) {
                if (url_params_keys[i].indexOf('filter_') > -1 || url_params_keys[i] == 'order_by') {
                    $('body').addClass('has-active-filters');
                    break;
                }
            }
        }
    })();

    $('.filters-view-more').each(function() {
        var $this = $(this);
        var $parent = $this.parent();
        var $items_list = $parent.find('.product-filter-list');
        var $items = $items_list.find('li');
        var $button = $parent.find('.filters-view-more');
        var items_count = $items.length;
        var items_count_collapsed = parseInt(items_count - 10);
        var items_height = 0;

        if (items_count > 10) {
            $([$('.filters'), $parent]).each(function(index, el) {
                $(el).css({
                    position: 'absolute',
                    visibility: 'hidden',
                    display: 'block'
                });
            });

            $items.each(function(index, el) {
                items_height += $(el).outerHeight();

                if (index < 10) {
                    $items_list.data('collapseHeight', items_height);
                }
                if (index == (items_count - 1)) {
                    $items_list.data('expandHeight', items_height);
                }
            });

            $([$('.filters'),$parent]).each(function(index, el){
                $(el).removeAttr('style');
            });
            $items_list.css({height: $items_list.data('collapseHeight'), overflow: 'hidden'});
            $button.text(lang.storefront.script.filter.see_all + ' (+'+ items_count_collapsed +')');
            $button.removeClass('hidden');
        }

        $this.on('click', function(e) {
            e.preventDefault();
            $items_list.data('style', $items_list.attr('style'));
            if ($this.attr('data-action') == 'expand') {
                //$items_list.removeAttr('style').css('height', $items_list.data('expandHeight'));
                $items_list.removeAttr('style');
                $button.text(lang.storefront.script.filter.see_less);
                $this.attr('data-action', 'collapse');
            } else {
                $items_list.css({height: $items_list.data('collapseHeight'), overflow: 'hidden'});
                $button.text(lang.storefront.script.filter.see_all + ' (+'+ items_count_collapsed +')');
                $this.attr('data-action', 'expand');
            }
        });
    });

    if (Modernizr.mq('(min-width: 992px)')) {
        $('.filters .list-group-item').each(function() {
            var _this = $(this);
            var toggle = $('.product-filter-title', _this);
            var list = $('.product-filter-list', _this);
            var active_count = list.find('.active').length;

            if (active_count) {
                toggle.trigger('click');
                return;
            }
        });
    }

    /*--
    ion Range Slider
    -----------------------------------*/
    $(".range-slider").ionRangeSlider({
        skin: "learts",
        hide_min_max: true,
        type: 'double',
        prettify: function(data) {
            return format_currency(data, store_currency);
        },
        onFinish: function(data)
        {
            var params = get_url_params();
            params.filter_price_min = data.from;
            params.filter_price_max = data.to;
            //params['_js'] = 'filter';

            location.href = generate_url(params);
        }
    });

    (function (){
        var params = get_url_params();
        if (window.location.pathname == '/' && params['option']) {
            delete params["option"];
            var url = generate_url(params);
            window.history.replaceState(null, null, url);
        }
    })();

    $('.order-options .dropdown-menu a').on('click', function(e) {
        e.preventDefault();
        var _this = $(this);
        var order = _this.attr('data-order');
        var params = get_url_params();
        params['order_by'] = order;

        location.href = generate_url(params);
    });

    $('.testimonial-carousel').slick({
        infinite: true,
        slidesToShow: 3,
        slidesToScroll: 1,
        arrows: false,
        dots: true,
        responsive: [{
                breakpoint: 991,
                settings: {
                    slidesToShow: 2
                }
            },
            {
                breakpoint: 767,
                settings: {
                    slidesToShow: 1
                }
            }
        ]
    });

    var media_query = window.matchMedia('(max-width: 767px)');
    media_query.addEventListener('change', function(e) {
        handle_breakpoint_change(e, theme_options);
    });
    handle_breakpoint_change(media_query, theme_options);

    var limit_birthday_date = new Date().toISOString().split('T')[0];
    $('.page-account-profile #birthday').attr('max', limit_birthday_date);

    // Video hover effect for product listings
    $(document).on({
        mouseenter: function() {
            var $this = $(this);
            var $video = $this.find('.product-hover-video');
            var $thumb = $this.find('.product-thumb');

            $thumb.css('visibility', 'hidden');
            $video.css('visibility', 'visible')[0].play();
        },
        mouseleave: function() {
            var $this = $(this);
            var $video = $this.find('.product-hover-video');
            var $thumb = $this.find('.product-thumb');
            var video = $video[0];

            video.pause();
            video.currentTime = 0;
            $video.css('visibility', 'hidden');
            $thumb.css('visibility', 'visible');
        }
    }, '.product-list.has-video');
});

$(window).load(function() {
    if ($('.home-products .nav-home-products li').length > 0) {
        $('.home-products .nav-home-products li:visible:first a').trigger('click');
    }

    $('.fb-page, .fb-comments').each(function() {
        $(this).attr('data-width', $(this).parent().width());
    });

    //Force first option to be triggered
    if (typeof product !== 'undefined' && product.option_groups.length > 0) {
        product_options(product, true);
    }

    $('.intl-validate').each(function(index) {
        var _this = $(this);
        var address_type = _this.attr('id').split('_')[0];
        setTimeout(function() {
            if (!_this.val() && user[address_type].country_code_alpha_2) {
                _this.intlTelInput('setCountry', user[address_type].country_code_alpha_2);
            }
            validate_phone_intl_input(_this, true);
            _this.blur();
        }, 1500);
    });

    $('#cupao').keypress(function (e) {
        if (e.which == 13) {
            e.preventDefault();
            $(this).parents('.coupon-code-input').find('button[type="submit"]').trigger('click');
            return false;
        }
    });
});


$('.shipping-methods .list-radio-block').on('click', function(e) {
    var _this = $(this);
    $('.shipping-methods .list-radio-block').removeClass('list-group-item-active').find('input').prop('checked', false);
    $('select', _this).length ? $('select', _this).prop('disabled', false) : $('.shipping-methods .list-radio-block:not(.list-group-item-active)').find('select').prop('disabled', true);
    _this.addClass('list-group-item-active').find('input').prop('checked', true).trigger('change');
});
$('.payment-methods .list-radio-block').on('click', function(e) {
    var _this = $(this);
    $('.payment-methods .list-radio-block').removeClass('list-group-item-active').find('input').prop('checked', false);
    _this.addClass('list-group-item-active').find('input').prop('checked', true).trigger('change');
    $('#pick_up_location', _this).length ? $('#pick_up_location', _this).prop('required', true) : $('.payment-methods').find('#pick_up_location').prop('required', false);
});

function enable_shipping() {
    $('.shipping-methods').removeClass('disabled').find('input').prop('disabled', false);
}

function disable_shipping() {
    $('.shipping-methods').addClass('disabled').find('input').prop('disabled', true);
}

function check_shipping(el) {
    if (el.prop('value') == 'pick_up') {
        disable_shipping();
    } else {
        enable_shipping();
    }
}

function product_options(product, onload) {
    onload = typeof onload !== 'undefined' ? onload : false;

    if ($('.select-product-options').length) {
        $('.add-cart').fadeTo('fast', 0.25).removeClass('form-enabled');

        var default_option = product_default_option(product);

        $('.select-product-options').each(function(i) {
            if (onload == true) {
                $('option[value="' + default_option[i] + '"]', this).prop('selected', true);
            }
            var option = $('option:selected', this);
            window['id_variant_' + (i + 1)] = option.attr('value');
        });

        if ($('.select-product-options').length == 1 && onload == true) {
            $.each(product.options, function(key, option){
                var $option = $('.select-product-options option[value="'+ option.id_variant_1 +'"]'),
                    $option_text = $option.text();
                if (option.price_on_request) {
                    $option_text += (' - ' + lang.storefront.macros.product.price_on_request);
                } else {
                    if (option.price !== null) {
                        var option_display_price = option.promo ? option.price_promo_formatted : option.price_formatted;
                        option_display_price += product.stock.stock_enabled && !product.stock.stock_backorder && !option.stock ? ('  (' + lang.storefront.script.product.not_available + ')') : '';
                        $option_text += ' - ' + option_display_price;
                    }
                }
                $option.text($option_text);
            });
        }

        var data_product_options = { all: true, id_variant_1: window.id_variant_1, id_variant_2: window.id_variant_2, id_variant_3: window.id_variant_3 };
        var product_handle = product.handle;
        var disable_form_product;

        $.post('/product-options/' + product_handle, data_product_options, function(response) {

            var price_txt;
            var stock_qty;

            $('.add-cart').fadeTo('fast', 1);

            if (response && response.active) {
                if (response.price_on_request === true) {
                    $('body').addClass('price-on-request');

                    price_txt = lang.storefront.macros.product.price_on_request;
                    disable_form_product = true;
                } else {
                    $('body').removeClass('price-on-request');

                    if (product_is_vendible(product, response)) {

                        $('.product-detail .data-price-non-wholesale').text(response.price_non_wholesale_formatted);

                        if (response.promo === true) {
                            $('.promo-price').text(response.price_formatted);
                            price_txt = response.price_promo_formatted;

                            if (response.price_promo_percentage) {
                                $('.product-detail .promo-percentage').removeClass('hidden');
                                $('.product-detail .data-promo-percentage').text(response.price_promo_percentage);
                            } else {
                                $('.product-detail .promo-percentage').addClass('hidden');
                            }
                        } else {
                            $('.promo-price').text('');
                            price_txt = response.price_formatted;
                            $('.product-detail .promo-percentage').addClass('hidden');
                            $('.product-detail .data-promo-percentage').text('');
                        }

                        if (response.rewards) {
                            $('#message-points').text(response.rewards);
                            $('#message-points').parents('.callout').removeClass('hidden');
                        } else {
                            $('#message-points').parents('.callout').addClass('hidden');
                        }

                        $('.extra-options').removeClass('hidden').find('input, select, textarea').prop('disabled', false);

                        disable_form_product = false;
                    } else {
                        price_txt = lang.storefront.script.product.not_available;
                        disable_form_product = true;
                    }

                    stock_qty = response.stock_qty;
                }

                if (response.image && response.image.full.indexOf('no-img') <= 0) {
                    var image_selected = $('.product-thumbs a').find('img[src="' + response.image.square + '"]').first();

                    // Use existing API or initialize if needed
                    var api = $('.easyzoom').data('easyZoom') || initialize_easyzoom($('.easyzoom'), 'Loading ...');
                    api = change_product_image(api, image_selected.parent());

                    $('.product-thumbs').scrollTo($('.thumb a.active').parent(), 500, {offset: -$('.thumb a.active').width()});
                }

                if (response.wishlist) {
                    if (response.wishlist.status) {
                        wishlist_html = helper_icon_render('heart') + ' ' + lang.storefront.product.wishlist.remove;
                        wishlist_url = response.wishlist.remove_url;
                        $('.wishlist').addClass('added');
                    } else {
                        wishlist_html = helper_icon_render('heart') + ' ' + lang.storefront.product.wishlist.add;
                        wishlist_url = response.wishlist.add_url;
                        $('.wishlist').removeClass('added');
                    }
                    $('.wishlist a').html(wishlist_html).attr('href', wishlist_url);

                    if ($('body').hasClass('feather')) {
                        feather.replace();
                    }
                }

                reference = response.reference;
                barcode = response.barcode;
            } else {
                $('body').removeClass('price-on-request');
                price_txt = lang.storefront.script.product.not_available;
                stock_qty = 0;
                disable_form_product = true;
                reference = '';
                barcode = '';

                if (response && response.image && response.image.full.indexOf('no-img') <= 0) {
                    var image_selected = $('.product-thumbs a').find('img[src="' + response.image.square + '"]').first();

                    // Use existing API or initialize if needed
                    var api = $('.easyzoom').data('easyZoom') || initialize_easyzoom($('.easyzoom'), 'Loading ...');
                    api = change_product_image(api, image_selected.parent());

                    $('.product-thumbs').scrollTo($('.thumb a.active').parent(), 500, {offset: -$('.thumb a.active').width()});
                }
            }

            $(document).trigger('trigger_product_options', response);

            if (disable_form_product === true) {
                $('.promo-price').text('');
                $('.product-detail .promo-percentage').addClass('hidden');
                $('.extra-options').addClass('hidden').find('input, select, textarea').prop('disabled', true);
            }

            animate_updated_value('.data-product-price', price_txt, 'flash');
            animate_updated_value('.data-product-stock_qty', stock_qty, 'flash');
            animate_updated_value('span.sku', reference, 'flash');
            animate_updated_value('span.ean', barcode, 'flash');

            $('.add-cart input[name="qtd"], .add-cart button[type="submit"]').prop('disabled', disable_form_product);
            $('.add-cart').addClass('form-enabled');

            product_options_url();

        }, 'json');
    } else {
        $('.add-cart').addClass('form-enabled');
        $('.extra-options').removeClass('hidden').find('input, select, textarea').prop('disabled', false);
    }
}

function product_options_url() {
    $('.select-product-options').on('change', function() {
        var pathname = window.location.pathname;
        var origin = window.location.origin;
        var selected_option = { 0: null, 1: null, 2: null };
        var k = 0;

        $('.select-product-options').each(function(index, el) {
            selected_option[k] = $('option:selected', this).prop('value');
            ++k;
        });

        for (var i = 0; i < product.options.length; i++) {
            if (product.options[i].id_variant_1 == selected_option[0] && product.options[i].id_variant_2 == selected_option[1] && product.options[i].id_variant_3 == selected_option[2]) {
                var option = product.options[i].id;
            }
        }

        if (option) {
            var url = UpdateQueryString('option', option);

            if (url) {
                if (window.history.replaceState) {
                    window.history.replaceState(null, null, url);
                }
            }
        }
    });

    return false;
}

function product_is_vendible(product, response) {
    //Check if there object is not null
    if (response) {
        //Check product stock
        if (product.stock.stock_enabled) {
            if (response.stock_qty > 0) {
                return true;
            } else {
                if (product.stock.stock_backorder) {
                    return true;
                } else {
                    return false;
                }
            }
        } else {
            return true;
        }
    } else {
        return false;
    }
}

//check product default option
function product_default_option(product) {
    var option = 'false';
    //get query string value
    var option_id = qs["option"];

    //set default option from query string
    if (typeof option_id !== 'undefined' && product.option_groups.length > 0) {
        for (var i = 0; i < product.options.length; i++) {
            if (product.options[i].id == option_id) {
                option = i;
            }
        }
    } else {
        //get default option
        for (var i = 0; i < product.options.length; i++) {
            if (product.options[i].active === true) {
                if (product.options[i].price_on_request === true) {
                    option = i;
                } else {
                    if (product.stock.stock_enabled) {
                        if (product.stock.stock_backorder || product.options[i].stock > 0) {
                            option = i;
                        }
                    } else {
                        option = i;
                    }
                }

                if ($.isNumeric(option)) {
                    i = product.options.length;
                }
            }
        }
    }

    if (isNaN(option)) {
        option = 0;
    }

    return option = {
        0: product.options[option].id_variant_1,
        1: product.options[option].id_variant_2,
        2: product.options[option].id_variant_3
    };
}

function animate_updated_value(selector, value, fx) {
    $(selector).text(value);
    $(selector).removeClass(fx + ' animated').addClass('flash animated').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
        $(this).removeClass(fx + ' animated');
    });
}

function home_load_more(el, lazy) {
    if (!el.length) {
        return false;
    }

    var _this = el;
    var params = _this.data();
    params['page'] = params['page'] ? params['page'] : 2;
    params['total_count'] = false;
    var url = params['href'];

    $.get(url, params, function(data) {
        if (data) {

            var output = $(data);
            output.data(params);
            output.addClass('loaded');

            $(_this).replaceWith(output);

            $(document).trigger('refresh_product_reviews_on_product_list');

            if ($('body').hasClass('feather')) {
                feather.replace();
            }
            lazy.update();
        }
    });

    _this.removeData('total_count');
}

// Helper functions for managing easyzoom
function initialize_easyzoom($element, loading_text) {
    var $easyzoom = $element.easyZoom({
        loadingNotice: loading_text || 'Loading ...'
    });
    return $easyzoom.filter('.easyzoom').data('easyZoom');
}

function teardown_easyzoom($element) {
    var api = $element.data('easyZoom');
    if (api && api.teardown) {
        api.teardown();
    }
}

// Helper function to create media HTML
function create_video_html(video_url, poster_url, video_alt) {
    return '<video controls muted autoplay loop poster="' + poster_url + '" class="img-responsive" width="600" aria-label="' + video_alt + '">' +
           '<source src="' + video_url + '" type="video/mp4">' +
           video_alt +
           '</video>';
}

function create_image_html(image_standard) {
    return '<a href="' + image_standard + '"><img src="' + image_standard + '" alt="" class="img-responsive"></a>';
}

function change_product_image(api, click_element) {
    var $product_image = $('.current-product-image');
    var $thumb_links = $('.product-thumbs a');

    $thumb_links.removeClass('active');

    // Check if the clicked element is a video
    if (click_element.data('video-url')) {
        // Handle video display
        var video_url = click_element.data('video-url');
        var poster_url = click_element.attr('href');
        var video_alt = click_element.data('video-alt');

        // Destroy easyzoom if it exists
        if ($product_image.hasClass('easyzoom')) {
            teardown_easyzoom($product_image);
        }

        // Replace with video
        $product_image.removeClass('easyzoom').html(create_video_html(video_url, poster_url, video_alt));
        api = null; // No zoom API for videos
    } else {
        // Handle image display
        var image_standard = click_element.data('standard');
        var image_href = click_element.attr('href');

        // Check if we need to restore easyzoom (coming from video or no API exists)
        if (!$product_image.hasClass('easyzoom') || $product_image.find('video').length > 0) {
            // Need to setup easyzoom from scratch
            $product_image.addClass('easyzoom').html(create_image_html(image_standard));

            // Initialize easyzoom
            api = initialize_easyzoom($product_image, 'Loading ...');
        } else {
            // Easyzoom exists, just swap the image
            var current_api = $product_image.data('easyZoom');
            if (current_api) {
                current_api.swap(image_standard, image_href);
                api = current_api;
            } else {
                // Fallback: reinitialize if API is missing
                api = initialize_easyzoom($product_image, 'Loading ...');
            }
        }
    }

    click_element.addClass('active');
    return api;
}

function get_url_params() {
    var query_strings = {};
    location.search.substr(1).split("&").forEach(function(item) {if(item){query_strings[item.split("=")[0]] = item.split("=")[1];}});
    return query_strings;
}

function generate_url(params, pathname='', remove_pagination=true) {
    var i = 0, key,
        url = '//' + location.host + location.pathname;
    var segments = location.pathname.split('/');

    if (!isNaN(segments[segments.length - 1]) && segments[segments.length - 1] == parseFloat(segments[segments.length - 1])) {
        segments.pop();
        url = '//' + location.host + segments.join('/');
    }

    if (pathname) {
        segments.push(pathname);
        url = '//' + location.host + segments.join('/');
    }

    for (key in params) {
        if (i === 0) {
            url += "?";
        } else {
            url += "&";
        }
        url += key;
        url += '=';
        url += params[key];
        i++;
    }
    return url;
}

function handle_breakpoint_change(e, theme_options) {
    var gallery_type = e.matches ? 'mobile' : 'desktop';

    destroy_slideshow();

    if (gallery_type === 'mobile') {
        load_slideshow('mobile', (theme_options.gallery_type === 'products' ? theme_options.gallery : theme_options.mobile_gallery), theme_options);
    } else {
        load_slideshow('desktop', theme_options.gallery, theme_options);
    }
}

function load_slideshow(type, gallery, theme_options) {
    if (type == 'mobile') {
        $('.slideshow').addClass('slideshow-mobile');
    } else {
        $('.slideshow').addClass('slideshow-home');
    }

    if (gallery && gallery.length) {
        for (var i = 0; i < gallery.length; i++) {
            var has_slide_content = (gallery[i].title || gallery[i].button || gallery[i].description) ? 'has-slide-content' : '';
            var slideshow_content = has_slide_content ? ('<div class="slide-content">' + (gallery[i].title ? (gallery[i].link ? '<h4 class="slide-title"><a href="'+gallery[i].link+'">'+gallery[i].title+'</a></h4>' : '<h4 class="slide-title">'+gallery[i].title+'</h4>') : '') + (gallery[i].description ? '<div class="slide-description">'+gallery[i].description+'</div>' : '') + (gallery[i].button ? '<div class="slide-button"><a href="'+gallery[i].button_link+'" '+(gallery[i].target_blank == '1' ? 'target="_blank"' : '' )+ 'class="btn btn-primary">'+gallery[i].button+'</a></div>' : '') + '</div>') : '';

            // Check if this slide is a video
            var slideshow_slide;
            if (gallery[i].is_video === true || gallery[i].is_video === 'true' || gallery[i].is_video === '1' || gallery[i].is_video === 1 || (gallery[i].video_url && gallery[i].video_url !== '' && gallery[i].video_url !== 'undefined')) {
                // Create video slide with video element instead of background image
                var video_url = gallery[i].video_url || gallery[i].url;
                // Get poster URL - handle both URL strings and IDs
                var poster_url;
                if (gallery[i].poster_url) {
                    // Use poster_url if available (full URL)
                    poster_url = gallery[i].poster_url;
                } else if (gallery[i].poster && !isNaN(gallery[i].poster)) {
                    // If poster is numeric (ID), skip it and use fallbacks
                    poster_url = gallery[i].thumbnail || gallery[i].image.full;
                } else {
                    // Use poster if it's a string URL, or fallback to thumbnail/image
                    poster_url = gallery[i].poster || gallery[i].thumbnail || gallery[i].image.full;
                }
                slideshow_slide = '<li class="slide slide-video '+has_slide_content+'">' +
                    '<video class="slide-video-element" autoplay muted playsinline '+(gallery.length == 1 ? 'loop' : '')+' poster="'+poster_url+'" data-size="'+theme_options.slideshow_background_size+'" aria-label="'+(gallery[i].image.alt ? gallery[i].image.alt : gallery[i].title)+'">' +
                    '<source src="'+video_url+'" type="video/mp4">' +
                    (gallery[i].image.alt ? gallery[i].image.alt : gallery[i].title) +
                    '</video>' +
                    slideshow_content +
                    '</li>';
            } else {
                // Regular image slide with background
                slideshow_slide = '<li class="slide '+has_slide_content+'" style="background-image:url('+gallery[i].image.full+')">' + slideshow_content + '</li>';
            }

            $('.slideshow .slides').append(slideshow_slide);
        }

        $('.slideshow-home, .slideshow-mobile').flexslider({
            slideshowSpeed: parseInt(theme_options.slideshow_slide_speed * 1000),
            animationSpeed: 1000,
            controlNav: true,
            directionNav: false,
            selector: ".slides > .slide",
            start: function(slider){
                $('.slideshow').addClass('loaded');

                var main_slideshow = $(slider[0]);
                var has_navigation = $(main_slideshow).find('.flex-control-nav');
                has_navigation.length ? main_slideshow.addClass('has-navigation') : main_slideshow.removeClass('has-navigation');

                // Play video in first slide if it exists
                var $firstSlide = $(slider.slides[0]);
                var $video = $firstSlide.find('.slide-video-element');
                if ($video.length) {
                    $video[0].play();


                    slider.pause();
                    $video.on('ended', function() {
                        slider.play();
                    });
                }
            },
            before: function(slider){
                // Pause all videos
                $('.slide-video-element').each(function() {
                    this.pause();
                });
            },
            after: function(slider){
                // Play video in current slide if it exists
                var $currentSlide = $(slider.slides[slider.currentSlide]);
                var $video = $currentSlide.find('.slide-video-element');
                if ($video.length) {
                    $video[0].play();

                    slider.pause();
                    $video.on('ended', function() {
                        slider.play();
                    });
                }
            }
        });

        $('.slideshow').removeClass('hidden');
    }
}

function destroy_slideshow() {
    var slideshow = $('.slideshow');
    if (slideshow.data('flexslider')) {
        // Pause and remove all videos before destroying
        $('.slide-video-element').each(function() {
            this.pause();
            this.src = '';
        });
        slideshow.removeData('flexslider');
        slideshow.off('.flexslider');
        slideshow.html('<div class="flexslider"><ul class="slides"></ul></div>');
    }
    slideshow.removeClass('slideshow-mobile slideshow-home loaded').addClass('hidden');
}

(function($) {
    $.fn.hasScrollBar = function() {
        return this.get(0).scrollWidth > this.get(0).clientWidth;
    };
})(jQuery);
