{# Macros #}

{# Video wrapper macro for product listings - DRY principle #}
{% macro video_wrapper(product, card_thumbnail_type, product_title, css_class = '') %}
    <div class="product-media-wrapper {{ css_class }}" data-has-video="true">
        <img src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ product.image[card_thumbnail_type] }}" alt="{{ product_title }}" title="{{ product_title }}" width="400" height="400" class="lazy primary-img product-thumb">
        <video class="product-hover-video" muted loop playsinline preload="none" src="{{ product.image.video_url }}" aria-label="{{ product.image.alt ? product.image.alt : product_title }}">
            <source src="{{ product.image.video_url }}" type="video/mp4">
            {{ product.image.alt ? product.image.alt : product_title }}
        </video>
    </div>
{% endmacro %}

{% macro product_list(product) %}
    {% import _self as generic_macros %}

    {% set product_title = product.title|e_attr %}
    {% set product_url = product.url %}
    {% set product_category = product.categories[0] %}
    {% set card_thumbnail_type = store.theme_options.catalog_thumbail_type == 'square' ? 'square' : 'thumb' %}
    {% set second_image = product.images[0][card_thumbnail_type] %}
    {% set show_product_second_image = store.theme_options.show_product_second_image == 'show' and second_image ? 'has-second-image' : '' %}
    {% set mobile_products_per_row = store.theme_options.mobile_products_per_row == '2' ? '6' : '12' %}
    {% set products_per_row = current_page == 'home' ? (store.theme_options.home_products_per_row is not null ? store.theme_options.home_products_per_row : '4') : (store.theme_options.products_per_row is not null ? store.theme_options.products_per_row : '4') %}
    {% set card_hover_effect = store.theme_options.card_hover_effect != 'none' ? store.theme_options.card_hover_effect : '' %}

    <article class="product-list product-id-{{ product.id }} {{ product.status_alias }} {{ store.theme_options.card_shadow }} {{ card_hover_effect }} {{ show_product_second_image }} {{ product.image.video_url ? 'has-video' : '' }}" data-id="{{ product.id }}">
        {% if product.promo == true and product.price_promo_percentage == true %}
            <div class="product-promo-percent promo-percentage">-<span>{{ product.price_promo_percentage }}</span>%</div>
        {% endif %}
        <div class="product-wrapper">
            <a href="{{ product_url }}" class="relative">
                <span class="product-badges" data-position="{{ store.theme_options.badges_position }}">
                    {% if product.status_alias == 'out_of_stock' %}
                        <span class="badge out_of_stock" >{{ 'lang.storefront.macros.product.badge.out_of_stock'|t }}</span>
                    {% elseif product.status_alias == 'soon' %}
                        <span class="badge soon">{{ 'lang.storefront.macros.product.badge.soon'|t }}</span>
                    {% elseif product.promo == true %}
                        {# {% if product.price_promo_percentage == true %}
                            <div class="product-promo-percent promo-percentage">-<span>{{ product.price_promo_percentage }}</span>%</div>
                        {% endif %} #}
                        <span class="badge promo" data-has-percentage="{{ product.price_promo_percentage == true ? 'true' : 'false' }}">{{ 'lang.storefront.macros.product.badge.promo'|t }}</span>
                    {% elseif product.new == true %}
                        <span class="badge new">{{ 'lang.storefront.macros.product.badge.new'|t }}</span>
                    {% endif %}
                </span>
                {% if product.image.video_url %}
                    {# Use shared video wrapper macro #}
                    {{ _self.video_wrapper(product, card_thumbnail_type, product_title) }}
                {% else %}
                    <img src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ product.image[card_thumbnail_type] }}" alt="{{ product.image.alt ? product.image.alt : product_title }}" title="{{ product_title }}" width="400" height="400" class="lazy primary-img">
                {% endif %}
                {% if show_product_second_image %}
                    <span class="secondary-img">
                        <img src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ second_image }}" alt="{{ product.images[0].alt ? product.images[0].alt : product_title }}" title="{{ product_title }}" class="lazy">
                    </span>
                {% endif %}
            </a>
            <div class="product-list-details">
                <h3><a href="{{ product_url }}" class="link-inherit">{{ product_title }}</a></h3>
                {% if product_category.active %}
                    <h6 class="hidden-xs"><a href="{{ product_category.url }}" class="link-inherit">{{ product_category.title }}</a></h6>
                {% endif %}
                <span class="price">
                    {% if product.price_range %}
                        {{ product.price_min|money_with_sign }} — {{ product.price_max|money_with_sign }}
                    {% elseif product.price_on_request == true %}
                        {{ 'lang.storefront.macros.product.price_on_request'|t }}
                    {% else %}
                        {% if product.promo == true %}
                             {{ product.price_promo | money_with_sign }} <del>{{ product.price | money_with_sign }}</del>
                        {% else %}
                            {{ product.price | money_with_sign }}
                        {% endif %}
                    {% endif %}
                </span>
            </div>
            <div class="product-list-expand {{ store.theme_options.card_shadow }}">
                {% if product.description_short %}<div class="short-description hidden-xs">{{ product.description_short }}</div>{% endif %}
                {% if product.status == 1 and product.price_on_request == false and not (product.option_groups or product.extra_options) and not (apps.upload_file and apps.upload_file.page == 'product' and apps.upload_file.required == true) %}
                    <a href="{{ product.add_cart_url }}" class="btn btn-primary {{ store.theme_options.button_primary_shadow }} {{ products_per_row > 4 ? 'btn-sm' : '' }}">{{ icons('shopping-basket') }} {{ products_per_row == 6 ? '' : 'lang.storefront.layout.button.buy'|t }}</a>
                {% elseif product.option_groups or product.extra_options %}
                    <a href="{{ product_url }}" class="btn btn-primary {{ store.theme_options.button_primary_shadow }} {{ products_per_row > 4 ? 'btn-sm' : '' }}">{{ icons('plus-square') }} {{ products_per_row == 6 ? '' : 'lang.storefront.macros.product.options'|t }}</a>
                {% else %}
                    <a href="{{ product_url }}" class="btn btn-primary {{ store.theme_options.button_primary_shadow }} {{ products_per_row > 4 ? 'btn-sm' : '' }}">{{ icons('plus-square') }} {{ products_per_row == 6 ? '' : 'lang.storefront.macros.product.info'|t }}</a>
                {% endif %}
            </div>
        </div>
    </article>
{% endmacro %}

{% macro product_list_media(product) %}
    {% set product_title = product.title %}
    {% set card_thumbnail_type = store.theme_options.catalog_thumbail_type == 'square' ? 'square' : 'thumb' %}

    <div class="media">
        <a class="media-left media-top" href="{{ product.permalink }}">
            <img class="lazy" src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ product.image[card_thumbnail_type] }}" alt="{{ product.image.alt ? product.image.alt : product_title }}" title="{{ product_title }}" width="50">
        </a>
        <div class="media-body">
            <h5 class="media-heading"><a href="{{ product.permalink }}" class="link-inherit">{{ product_title }}</a></h5>
            {% if product.price_on_request == true %}
                <span class="price">{{ 'lang.storefront.macros.product.price_on_request'|t }}</span>
            {% else %}
                {% if product.promo == true %}
                     <span class="price">{{ product.price_promo | money_with_sign }}</span> &nbsp; <del class="small text-muted">{{ product.price | money_with_sign }}</del>
                {% else %}
                    <span class="price">{{ product.price | money_with_sign }}</span>
                {% endif %}
            {% endif %}
        </div>
    </div>
{% endmacro %}

{% macro category_list(category, show_number_products = true) %}
    {% import _self as generic_macros %}

    {% set category_title = category.title|e_attr %}
    {% set category_url = category.url %}
    {% set button_primary_shadow = store.theme_options.button_primary_shadow == 'block' ? 'btn-shadow' : '' %}
    {% set card_hover_effect = store.theme_options.card_hover_effect != 'none' ? store.theme_options.card_hover_effect : '' %}
    {% set card_thumbnail_type = store.theme_options.catalog_thumbail_type == 'square' ? 'square' : 'thumb' %}

    <article class="category-list category-id-{{ category.id }} {{ store.theme_options.card_shadow }} {{ card_hover_effect }}">

        <div class="category-wrapper">
            <a href="{{ category_url }}"><img src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ category.image[card_thumbnail_type] }}" alt="{{ category.image.alt ? category.image.alt : category_title }}" title="{{ category_title }}" class="lazy" width="400" height="400"></a>
            <div class="category-list-details">
                <h3><a href="{{ category_url }}" class="link-inherit">{{ category_title }}</a></h3>
                {% if not category.parent == 0 and category.children and show_number_products %}
                    <p>{{ category.children|length }} {{ 'lang.storefront.layout.categories.title'|t }}</p>
                {% elseif show_number_products %}
                    <p>{{ category.total_products }} {{ 'lang.storefront.macros.products.title'|t }}</p>
                {% endif %}
            </div>
            <div class="category-list-expand {{ store.theme_options.card_shadow }}">
                <a href="{{ category_url }}" class="btn btn-primary {{ store.theme_options.button_primary_shadow }}">{{ icons('plus-square') }} {{ 'lang.storefront.macros.button.explore'|t }}</a>
            </div>
        </div>
    </article>
{% endmacro %}

{% macro order_by(get, order_options) %}
    <div class="order-options">
        <small>{{ 'lang.storefront.layout.order_options.label'|t }}</small> &nbsp;
        <div class="btn-group">

            <button type="button" class="btn btn-default {{ store.theme_options.button_default_shadow }} btn-sm dropdown-toggle" data-toggle="dropdown">
                {% for order_option, order_title in order_options %}
                    {% if order_option == get.order_by %}
                        {{ order_title }}
                    {% endif %}
                {% endfor %}
                <span class="caret"></span>
            </button>

            <ul class="dropdown-menu dropdown-menu-right well-featured {{ store.theme_options.well_featured_shadow }}" role="menu">
                {% for order_option, order_title in order_options %}
                    {% if order_option != get.order_by and (order_option != 'rating' or (order_option == 'rating' and apps.product_reviews))  %}
                        <li><a href="#" data-order="{{ order_option }}">{{ order_title }}</a></li>
                    {% endif %}
                {% endfor %}
            </ul>
        </div>
    </div>
{% endmacro %}

{% macro filters_list(category = null, tag = null, brand = null, param = null, get = null) %}
    {% if get.filter_custom_fields %}
        {% set custom_fields_param = 'custom_fields:' ~ get.filter_custom_fields|split('|')|join(' custom_fields:') %}
    {% endif %}

    {% set active_filters = "filter_price:[#{get.filter_price_min},#{get.filter_price_max}] filter_tag:#{get.filter_tags} filter_brand:#{get.filter_brands} filter_category:#{get.filter_categories} filter_stock:#{get.filter_stock} filter_promo:#{get.filter_promo} filter_new:#{get.filter_new} filter_rating:#{get.filter_rating} #{custom_fields_param}" %}
    {% set filters_list = filters("#{param} category:#{category.id} tag:#{tag.handle} brand:#{brand.id} #{active_filters}") %}

    <input type="hidden" value="{{ filters_list.active_filters|length|default(0) }}" class="active-filters-count">

    {% if filters_list.active_filters %}
        <div class="filters panel well-featured margin-bottom {{ store.theme_options.well_featured_shadow }}">
            <div class="panel-heading">
                <h4 class="product-filter-title margin-top-xxs margin-bottom-xxs bold">{{ 'lang.storefront.macros.filters.active_filters'|t }} <span class="text-muted normal">({{ filters_list.active_filters|length }})</span></h4>
            </div>
            <div class="list-group ">
                <div class="list-group-item product-active-filters">
                    <ul class="product-filter-list">
                        {% for active_filter in filters_list.active_filters %}
                            <li class="margin-0"><a href="#" data-filter="{{ active_filter.url|base64_encode }}" title="{{ 'lang.storefront.macros.filters.remove_filter'|t }}" class="remove-filter no-border">{{ icons('times') }}</a> {{ active_filter.title }}</li>
                        {% endfor %}
                    </ul>
                    <div class="filter-clear margin-top-xs">
                        <a href="#" class="clean-filter small text-underline text-muted">{{ 'lang.storefront.macros.filters.clean_filters'|t }}</a>
                    </div>
                </div>
            </div>
        </div>
    {% endif %}

    <div class="filters panel well-featured {{ store.theme_options.well_featured_shadow }}">
        <div class="panel-heading">
            <h4 class="product-filter-title margin-top-xxs margin-bottom-xxs bold">{{ 'lang.storefront.macros.filters.title'|t }}</h4>
        </div>
        <div class="list-group ">
            {% for filter_type in filters_list %}
                {% if filter_type.alias == 'custom_fields' and filter_type.filters %}
                    {% for custom_field_filters in filter_type.filters %}
                        <div class="list-group-item" data-id="{{ custom_field_filters.id }}">
                            <a class="semi-bold product-filter-title margin-0" data-toggle="collapse" data-target="#custom-fields-{{ custom_field_filters.id }}" aria-expanded="false" aria-controls="custom-fields-{{ custom_field_filters.id }}">{{ custom_field_filters.title }} {{ icons('angle-right') }}</a>
                            <div class="collapse" id="custom-fields-{{ custom_field_filters.id }}">
                                <ul class="product-filter-list product-filter">
                                    {% for filter in custom_field_filters.filters %}
                                        <li>
                                            <a href="#" data-filter="{{ filter.url|base64_encode }}" title="{{ 'lang.storefront.macros.filters.add_filter'|t }}" class="{{ filter.active }}">
                                                <span class="checkbox"></span>
                                                <span class="filter-title">{{ filter.title }}</span>
                                                <span class="count">{{ filter.num_products is defined ? filter.num_products : '' }}</span>
                                            </a>
                                        </li>
                                    {% endfor %}
                                </ul>
                                <a href="#" class="filters-view-more small text-underline text-muted hidden" data-action="expand"></a>
                            </div>
                        </div>
                    {% endfor %}
                {% elseif filter_type.alias == 'price_range' %}
                    {% set slider_from = get.filter_price_min is not null ? get.filter_price_min : filter_type.filters.price_min  %}
                    {% set slider_to = get.filter_price_max is not null ? get.filter_price_max : filter_type.filters.price_max  %}
                    <div class="list-group-item" data-type="{{ filter_type.alias }}">
                        <a class="semi-bold product-filter-title" data-toggle="collapse" data-target="#price-range" aria-expanded="false" aria-controls="price-range">{{ filter_type.title }} <span class="pull-right">{{ icons('angle-right') }}</span></a>
                        <div class="collapse" id="price-range">
                            <div class="price-range">
                                <input class="range-slider" type="text" data-min="{{ filter_type.filters.price_min }}" data-max="{{ filter_type.filters.price_max }}" data-from="{{ slider_from|e }}" data-to="{{ slider_to|e }}" />
                            </div>
                        </div>
                    </div>
                {% elseif filter_type.alias == 'rating' %}
                    <div class="list-group-item" data-type="{{ filter_type.alias }}">
                        <a class="semi-bold product-filter-title" data-toggle="collapse" data-target="#filters-{{ filter_type.alias }}" aria-expanded="false" aria-controls="filters-{{ filter_type.alias }}">{{ filter_type.title }} {{ icons('angle-right', 'pull-right') }}</a>
                        <div class="collapse" id="filters-{{ filter_type.alias }}">
                            <ul class="product-filter-list">
                                {% for filter in filter_type.filters %}
                                    <li {{ filter.num_products is defined and filter.num_products == 0 ? 'class="disabled"' }}>
                                        <a href="#" data-filter="{{ filter.url|base64_encode }}" title="Adicionar filtro" class="{{ filter.active }}">
                                            <span class="checkbox"></span>
                                            <span class="filter-stars">
                                                <div style="height:22px;" class="filters_review_rating_readonly" data-initial-rating="{{ filter.rating }}" data-active-color="orange" data-star-size="22"></div>
                                            </span>
                                            <span class="count">{{ filter.num_products is defined ? filter.num_products : '' }}</span>
                                        </a>
                                    </li>
                                {% endfor %}
                            </ul>
                        </div>
                    </div>
                {% else %}
                    {% if filter_type.filters %}
                        <div class="list-group-item" data-type="{{ filter_type.alias }}">
                            <a class="semi-bold product-filter-title" data-toggle="collapse" data-target="#filters-{{ filter_type.alias }}" aria-expanded="false" aria-controls="filters-{{ filter_type.alias }}">{{ filter_type.title }} <span class="pull-right">{{ icons('angle-right') }}</span></a>
                            <div class="collapse" id="filters-{{ filter_type.alias }}">
                                <ul class="product-filter-list">
                                    {% for filter in filter_type.filters %}
                                        <li {{ filter.num_products is defined and filter.num_products == 0 ? 'class="disabled"' }}>
                                            <a href="#" data-filter="{{ filter.url|base64_encode }}" title="{{ 'lang.storefront.macros.filters.add_filter'|t }}" class="{{ filter.active }}">
                                                <span class="checkbox"></span>
                                                <span class="filter-title">{{ filter.title }}</span>
                                                <span class="count">{{ filter.num_products is defined ? filter.num_products : '' }}</span>
                                            </a>
                                        </li>
                                        {% if filter.childrens %}
                                            {% for child_filter in filter.childrens %}
                                                <li class="child-filter">
                                                    <a href="#" data-filter="{{ child_filter.url|base64_encode }}" title="{{ 'lang.storefront.macros.filters.add_filter'|t }}" class="{{ child_filter.active }}">
                                                        <span class="checkbox"></span>
                                                        <span class="filter-title">{{ icons('level-up') }} {{ child_filter.title }}</span>
                                                        <span class="count">{{ child_filter.num_products is defined ? child_filter.num_products : '' }}</span>
                                                    </a>
                                                </li>
                                                {% if child_filter.childrens %}
                                                    {% for subchild_filter in child_filter.childrens %}
                                                        <li class="subchild-filter">
                                                            <a href="#" data-filter="{{ subchild_filter.url|base64_encode }}" title="{{ 'lang.storefront.macros.filters.add_filter'|t }}" class="{{ subchild_filter.active }}">
                                                                <span class="checkbox"></span>
                                                                <span class="filter-title">{{ icons('level-up') }} {{ subchild_filter.title }}</span>
                                                                <span class="count">{{ subchild_filter.num_products is defined ? subchild_filter.num_products : '' }}</span>
                                                            </a>
                                                        </li>
                                                    {% endfor %}
                                                {% endif %}
                                            {% endfor %}
                                        {% endif %}
                                    {% endfor %}
                                </ul>
                                <a href="#" class="filters-view-more small text-underline text-muted hidden" data-action="expand"></a>
                            </div>
                        </div>
                    {% endif %}
                {% endif %}
            {% endfor %}
        </div>
    </div>
{% endmacro %}

{% macro google_translate(apps_google_translate) %}
    {% set default_lang = apps_google_translate.default_language %}

    <div class="languages-dropdown btn-group pull-right hidden">
        <button type="button" class="btn btn-sm btn-default {{ store.theme_options.button_default_shadow }} dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            <span class="current-language"><span class="flag-icon"></span></span>&nbsp;
            <span class="caret"></span>
        </button>
        <ul class="dropdown-menu well-featured {{ store.theme_options.well_featured_shadow }}">
            <li class="googtrans-{{ default_lang }}"><a href="{{ current_url() }}" lang="{{ default_lang }}"><span class="flag-icon flag-icon-{{ apps_google_translate.flags[default_lang] }}"></span></a></li>
            {% for lang in apps_google_translate.languages|split(',') %}
                {% if lang != default_lang %}
                    <li class="googtrans-{{ lang }}"><a href="#googtrans({{ lang }})" lang="{{ lang }}"><span class="flag-icon flag-icon-{{ apps_google_translate.flags[lang] }}"></span></a></li>
                {% endif %}
            {% endfor %}
        </ul>
    </div>
{% endmacro %}

{% macro gallery() %}
    {% import _self as generic_macros %}
    {% if (store.gallery or store.theme_options.mobile_gallery) and (current_page in store.theme_options.gallery_location or 'all' in store.theme_options.gallery_location) %}
        <section class="slideshow {{ store.theme_options.slideshow_full_height }} {{ store.theme_options.slideshow_mobile_full_height }}">
            <div class="loader">{{ icons('sync', 'fa-spin') }}</div>
            <div class="flexslider">
                <ul class="slides"></ul>
            </div>
        </section>
    {% endif %}
{% endmacro %}

{% macro cart_notice() %}
    {% if store.theme_options.cart_notice and current_page in store.theme_options.cart_notice_location %}
        <div class="callout callout-info {{ store.theme_options.well_info_shadow }}">
            {{ store.theme_options.cart_notice }}
        </div>
    {% endif %}
{% endmacro %}

{% macro user_actions(user) %}
	<div class="user-actions">
		<ul>
            {% if store.settings.cart.users_registration != 'disabled' %}
                <li class="user-auth">
                    {% if user.is_logged_in %}
                        <div class="user-loggedin">
                            <a href="{{ site_url('account') }}" class="link-account link-inherit">{{ icons('user') }} <span class="user-name">{{ 'lang.storefront.layout.greetings'|t }} <strong>{{ user.name|first_word }}</strong></span></a>
                            <ul class="dropdown-user-actions dropdown-menu dropdown-menu-hover dropdown-menu-right hidden-xs well-featured {{ store.theme_options.well_featured_shadow }}">
                                <li class="{{ current_page == 'account-orders' ? 'active' }}"><a href="{{ site_url('account/orders')}}">{{ icons('shopping-bag') }} {{ 'lang.storefront.layout.orders.title'|t }}</a></li>
                                <li class="{{ current_page == 'account-profile' ? 'active' }}"><a href="{{ site_url('account/profile')}}">{{ icons('user') }} {{ 'lang.storefront.layout.client.title'|t }}</a></li>
                                <li class="{{ current_page == 'account-wishlist' ? 'active' }}"><a href="{{ site_url('account/wishlist')}}">{{ icons('heart') }} {{ 'lang.storefront.layout.wishlist.title'|t }}</a></li>
                                {% if store.settings.rewards.active %}<li class="{{ current_page == 'account-rewards' ? 'active' }}"><a href="{{ site_url('account/rewards')}}">{{ icons('trophy') }} {{ store.settings.rewards.plural_label ?: 'lang.storefront.account.rewards.plural.label'|t }} ({{ user.rewards }})</a></li>{% endif %}
                                <li><a href="{{ site_url('account/logout')}}">{{ icons('sign-out') }} {{ 'lang.storefront.layout.logout.title'|t }}</a></li>
                            </ul>
                        </div>
                    {% else %}
                        <a href="{{ site_url('signin') }}">{{ icons('user') }}</a>
                    {% endif %}
                </li>
                <li class="user-wishlist">
                    <a href="{{ user.is_logged_in ? site_url('account/wishlist') : site_url('signin') }}">{{ icons('heart') }}</a>
                </li>
            {% endif %}
            <li class="user-cart">
                <a class="link-cart link-inherit" href="{{ site_url('cart') }}">
                    {{ icons('shopping-basket') }} <span class="cart-total hidden-xs">{{ cart.subtotal | money_with_sign }}</span>
                    {% if cart.item_count > 0 %}
                        <span class="cart-num-products">{{ cart.item_count > 9 ? '9+' : cart.item_count }}</span>
                    {% endif %}
                </a>

                {% if cart.items %}
                    <ul class="dropdown-user-actions dropdown-user-actions-cart dropdown-menu dropdown-menu-hover dropdown-menu-right hidden-xs well-featured {{ store.theme_options.well_featured_shadow }}">
                        {% for item in cart.items %}
                            <li data-product="{{ item.product_id }}" data-product-option="{{ item.options|keys[0] }}">
                                <div class="image">
                                    <a href="{{ item.product_url }}"><img src="{{ assets_url('assets/store/img/no-img.png') }}" class="lazy" data-src="{{ item.image }}" alt="{{ item.image.alt ? item.image.alt : item.title|e_attr }}" title="{{ item.title|e_attr }}"></a>
                                </div>
                                <div class="item">
                                    <a href="{{ item.product_url }}"><strong class="qty">{{ item.qty }}x</strong> {{ item.title }}</a>

                                    {% if item.extras %}
                                        <div class="items-extra-wrapper">
                                            {% set item_extra_tip = '' %}
                                            {% for key, extra in item.extras %}
                                                {% set item_extra_tip = item_extra_tip ~ extra.title ~': '~ extra.value ~ (loop.last ? '' : '</br>') %}
                                            {% endfor %}
                                            <span href="#item-extra-{{ item.item_id }}" class="margin-top-xxs inline-block small text-default" data-toggle="tooltip" title="{{ item_extra_tip }}" data-html="true">{{ item.extras|length }} {{ item.extras|length > 1 ? 'lang.storefront.product.extra_options.plural.label'|t : 'lang.storefront.product.extra_options.singular.label'|t }} <span class="text-muted">({{ item.subtotal_extras > 0 ? item.subtotal_extras | money_with_sign : 'lang.storefront.cart.order_summary.shipping_total.free'|t }})</span></span>
                                        </div>
                                    {% endif %}

                                    <span class="price">{{ item.price | money_with_sign }}</span>
                                </div>
                                <div class="actions">
                                    <a href="{{ item.remove_link }}">{{ icons('trash-alt') }}</a>
                                </div>
                            </li>
                        {% endfor %}
                        <li class="cart-subtotal">
                            <h5>{{ 'lang.storefront.layout.subtotal.title'|t }}</h5>
                            <h3 class="price">{{ cart.subtotal | money_with_sign }}</h3>
                            <div class="cart-buttons">
                                <a href="{{ site_url('cart') }}" class="btn btn-primary {{ store.theme_options.button_primary_shadow }}">{{ 'lang.storefront.layout.button.see_cart'|t }}</a>
                                <a href="{{ site_url('cart/data') }}" class="btn btn-default {{ store.theme_options.button_default_shadow }}">{{ 'lang.storefront.layout.button.checkout'|t }}</a>
                            </div>
                        </li>
                    </ul>
                {% endif %}
            </li>
        </ul>
    </div>
{% endmacro %}

{% macro popup_interactions(popup) %}
    {% if popup.interaction == 'newsletter' and apps.newsletter %}
        <div class="popup-newsletter newsletter form-inline text-center">
            <input type="email" id="email_newsletter" name="email_newsletter" class="form-control input-lg" placeholder="{{ popup.interaction_newsletter_input_placeholder|e('html_attr') }}" required style="background-color:{{ popup.background_color }};color:{{ popup.text_color }};border-color:{{ popup.text_color }}">
            <button type="button" class="btn btn-no-shadow btn-lg submit-newsletter" data-dismiss="modal" data-unique_id="{{ popup.unique_id }}" style="background-color:{{ popup.text_color }};color:{{ popup.background_color }};border-color:{{ popup.text_color }}">{{ popup.interaction_newsletter_button_text }}</button>
        </div>
    {% endif %}
    {% if popup.interaction == 'button' %}
        <div class="popup-button text-center">
            <a href="{{ popup.interaction_button_button_link }}" class="btn btn-lg" data-unique_id="{{ popup.unique_id }}" {{ popup.interaction_button_button_target_blank ? 'target="_blank"' }} style="background-color:{{ popup.text_color }};color:{{ popup.background_color }};">{{ popup.interaction_button_button_text }}</a>
        </div>
    {% endif %}
{% endmacro %}

{% macro reviews_block(reviews) %}
    {% set layout_container = store.theme_options.layout_container == 'fluid' ? 'container-fluid' : 'container' %}
    {% if current_page in apps.product_reviews.product_reviews_block or 'all' in apps.product_reviews.product_reviews_block %}
        <section class="reviews-block block">
            <div class="{{ layout_container }}">
                <h3 class="text-center margin-bottom-xxs">{{ 'lang.storefront.about.reviews.title'|t }}</h3>

                <div class="row">
                    <div class="testimonial-carousel">
                        {% for review in reviews.reviews %}
                            <div class="col">
                                <a class="testimonial" href="{{ site_url('product') ~ '/' ~ review.product_handle }}">
                                    <div class="well well-default {{ store.theme_options.well_default_shadow }} margin-bottom-0">
                                        <h5 class="name">{{ review.name }}</h5>
                                        <div class="flex margin-bottom-xs">
                                            <span class="review-rating review-rating-stars" data-initial-rating="{{ review.rating }}" data-active-color="orange" data-star-size="15"></span>
                                            <small class="review-date margin-left-xxs">• {{ review.created_at|date("d/m/Y") }}</small>
                                        </div>
                                        <span class="text-muted small">{{ review.product_title }}</span>
                                        <p class="small">{{ review.body }}</p>
                                    </div>
                                </a>
                            </div>
                        {% endfor %}
                    </div>
                </div>
            </div>
        </section>
    {% endif %}
{% endmacro %}

{% macro product_campaign_block(campaign, price_vendible) %}
    {% if campaign.campaign_layout == 'callout_layout' or campaign.campaign_layout == 'show_countdown' %}
        {% set price_original = price_vendible / (1 - (campaign.value / 100)) %}
        {% set discount_value = price_original - price_vendible %}
        {% set campaign_start_date = campaign.start_date|format_datetime('long','none') ~ 'lang.storefront.helper.date_separation'|t ~ campaign.start_date|date("H:i") %}
        {% set campaign_end_date = campaign.end_date|format_datetime('long','none') ~ 'lang.storefront.helper.date_separation'|t ~ campaign.end_date|date("H:i") %}

        <div class="callout callout-warning callout-campaign {{ store.theme_options.well_warning_shadow }}">
            <h4>{{ icons('bullhorn') }} {{ campaign.title }}</h4>
            <p>{{ 'lang.storefront.product.campaign.full_description'|t([discount_value|money_with_sign, (campaign.value ~ '%'), campaign_start_date, campaign_end_date]) }}</p>

            {% if campaign.campaign_layout == 'show_countdown' %}
                <div class="campaign-countdown simply-countdown hidden {{ store.theme_options.well_default_shadow }}" data-start-date="{{ campaign.start_date }}" data-end-date="{{ campaign.end_date }}"></div>
            {% endif %}
        </div>
    {% endif %}
{% endmacro %}

{% macro product_campaign_simple(campaign) %}
    {% set campaign_start_date = campaign.start_date|format_datetime('long','none') ~ 'lang.storefront.helper.date_separation'|t ~ campaign.start_date|date("H:i") %}
    {% set campaign_end_date = campaign.end_date|format_datetime('long','none') ~ 'lang.storefront.helper.date_separation'|t ~ campaign.end_date|date("H:i") %}
    <p>{{ campaign.title }}. {{ 'lang.storefront.product.campaign.description'|t([campaign_start_date, campaign_end_date]) }}.</p><hr>
{% endmacro %}