{#
Description: Product Page
#}

{% macro wishlist_block(product, store) %}
    {% if store.settings.cart.users_registration != 'disabled' %}
        {% if not product.wishlist.status %}
            <p class="wishlist margin-top margin-bottom-0"><a href="{{ product.wishlist.add_url }}">{{ icons('heart') }} {{ 'lang.storefront.product.wishlist.add'|t }}</a></p>
        {% else %}
            <p class="wishlist margin-top-sm margin-bottom-0 added"><a href="{{ product.wishlist.remove_url }}">{{ icons('heart') }} {{ 'lang.storefront.product.wishlist.remove'|t }}</a></p>
        {% endif %}
    {% endif %}
{% endmacro %}

{% import _self as product_macros %}
{% import 'macros.tpl' as generic_macros %}

{% extends 'base.tpl' %}

{% block content %}

{% set product_is_vendible = product.status == 1 or (product.status == 3 and product.stock.stock_backorder) %}
{% set product_title = product.title|e_attr %}
{% set product_url = product.url %}

    <article class="product-detail">

        <div class="{{ layout_container }}">
            <ol class="breadcrumb hidden-xs">
                <li><a href="{{ site_url() }}">{{ 'lang.storefront.layout.breadcrumb.home'|t }}</a></li>
                {% if product.categories|first.active %}
                    <li><a href="{{ product.categories|first.url }}">{{ product.categories|first.title }}</a></li>
                {% endif %}
                <li class="active">{{ product_title }}</li>
            </ol>

            <div class="row">
                <div class="col-sm-6 col-md-6">
                    <div class="product-image">
                        {% if product.price_promo_percentage == true %}
                            <div class="product-promo-percent promo-percentage">-<span class="data-promo-percentage">{{ product.price_promo_percentage }}</span>%</div>
                        {% endif %}
                        <div class="current-product-image {% if not product.image.video_url %}easyzoom{% endif %}">
                            {% if product.image.video_url %}
                                {# Display video with controls #}
                                <video controls muted autoplay loop poster="{{ product.image.full }}" class="img-responsive" width="600" aria-label="{{ product.image.alt ? product.image.alt : product_title }}">
                                    <source src="{{ product.image.video_url }}" type="video/mp4">
                                    {{ product.image.alt ? product.image.alt : product_title }}
                                </video>
                            {% else %}
                                <a href="{{ product.image.full }}"><img src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ product.image.full }}" alt="{{ product.image.alt ? product.image.alt : product_title }}" title="{{ product_title }}" width="600" class="img-responsive lazy"></a>
                            {% endif %}
                        </div>

                        <div class="images">
                            <div class="row product-thumbs margin-top-sm">
                                <div class="thumb col-xs-3 col-md-3 col-lg-2">
                                    <a href="{{ product.image.full }}" data-standard="{{ product.image.full }}" class="active" {% if product.image.video_url %}data-video-url="{{ product.image.video_url }}" data-video-alt="{{ product.image.alt ? product.image.alt : product_title }}"{% endif %}>
                                        <img src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ product.image.square }}" class="img-responsive lazy" alt="{{ product.image.alt ? product.image.alt : product_title }}" title="{{ product_title }}">
                                        {% if product.image.video_url %}<span class="video-indicator-thumb">{{ icons('play-circle') }}</span>{% endif %}
                                    </a>
                                </div>

                                {% for image in product.images %}
                                    <div class="thumb col-xs-3 col-md-3 col-lg-2">
                                        <a href="{{ image.full }}" data-standard="{{ image.full }}" class="" {% if image.video_url %}data-video-url="{{ image.video_url }}" data-video-alt="{{ image.alt ? image.alt : product_title }}"{% endif %}>
                                            <img src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ image.square }}" class="img-responsive lazy" alt="{{ image.alt ? image.alt : product_title }}" title="{{ product_title }}">
                                            {% if image.video_url %}<span class="video-indicator-thumb">{{ icons('play-circle') }}</span>{% endif %}
                                        </a>
                                    </div>
                                {% endfor %}
                            </div>
                        </div>
                    </div>

                    {% if product.video_embed_url %}
                        <div class="embed-responsive embed-responsive-16by9 margin-top hidden-xs" data-service="{{ product.video_embed_url matches '/youtube/' ? 'youtube' : 'vimeo' }}" data-id="{{ product.video_embed_url|split('/')|last }}" data-ratio="16:9" data-autoscale>
                            {% if not apps.cookies or (apps.cookies and not apps.cookies.consent_mode) %}
                                <iframe width="560" height="315" src="{{ product.video_embed_url }}" allow="autoplay; encrypted-media" allowfullscreen></iframe>
                            {% endif %}
                        </div>
                    {% endif %}
                </div>
                <div class="col-sm-6 col-sm-offset-0 col-md-5 col-md-offset-1">
                    <div class="product-title-block">
                        <h1 class="product-title" >{{ product_title }}</h1>
                    </div>

                    {% set product_reference = product.reference and store.theme_options.show_product_sku == 'show' %}
                    {% set product_barcode = product.barcode and store.theme_options.show_product_barcode == 'show' %}
                    {% if product.stock.stock_show or product_reference or product_barcode %}
                        <p class="margin-top-xs text-muted product-stock-block">
                            {% if product.stock.stock_show %}
                                <span class="product-stock-qty">{{ 'lang.storefront.account.wishlist.stock_units'|t([product.stock.stock_qty]) }} {{ product_reference or product_barcode  ? ' | ' }}</span>
                            {% endif %}
                            {% if product_reference %}
                                <span class="product-sku">{{ 'lang.storefront.product.sku.label'|t }} <span class="sku">{{ product.reference }}</span>{{ product_barcode  ? ' | ' }}</span>
                            {% endif %}
                            {% if product_barcode %}
                                <span class="product-ean">{{ 'lang.storefront.product.ean.label'|t }} <span class="ean">{{ product.barcode }}</span></span>
                            {% endif %}
                        </p>
                    {% endif %}

                    {{ form_open_cart(product.id, { 'class' : 'add-cart well-featured ' ~ store.theme_options.well_featured_shadow }) }}
                        {% if product.option_groups and product_is_vendible %}
                            <div class="row margin-bottom">
                                {% for option_groups in product.option_groups %}
                                    <div class="col-md-{{ 12 / product.option_groups|length }}">

                                        <label for="{{ option_groups.title|slug }}">{{ option_groups.title }}</label>

                                        <select class="form-control select-product-options" name="option[]" id="{{ option_groups.title|slug }}">
                                            {% for option in option_groups.options %}
                                                <option value="{{ option.id }}" data-title="{{ option.title }}">
                                                    {{ option.title }}
                                                </option>
                                            {% endfor %}
                                        </select>
                                    </div>
                                {% endfor %}
                            </div>
                        {% endif %}

                        {% if product.extra_options %}
                            <div class="extra-options margin-bottom {{ product.option_groups or not product_is_vendible  ? 'hidden' : '' }}">
                                {% for extra_option in product.extra_options %}
                                    {% set field_disabled = extra_option.required ? '' : 'disabled' %}
                                    {% set field_required = extra_option.required ? 'required' : '' %}
                                    {% set field_checked = extra_option.required ? 'checked' : '' %}
                                    {% set field_hidden = extra_option.required ? '' : 'hidden' %}
                                    {% set field_size = extra_option.size ? 'maxlength="'~ extra_option.size ~'"' : 'maxlength="'~ (extra_option.type == 'textarea' ? '512' : '255') ~'"' %}
                                    {% set field_tip = extra_option.description ? '<span data-toggle="tooltip" data-placement="top" title="'~ extra_option.description ~'">' ~ icons('question-circle') ~ '</span>' : ''  %}
                                    {% set field_description = extra_option.description ? extra_option.description : 'lang.storefront.product.extra_options.type_value'|t %}

                                    <div class="extra-option margin-top-sm well {{ store.theme_options.well_default_shadow }} well-sm" data-id="{{ extra_option.alias }}">
                                        {% if extra_option.type == 'input' %}
                                            <div class="checkbox margin-0">
                                                <label>
                                                    <input type="checkbox" data-target="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" {{ field_required }} {{ field_checked }}>
                                                    {{ extra_option.title }}{{ extra_option.price ? ' - ' ~ extra_option.price_formatted : '' }}
                                                </label> {{ field_tip }}
                                            </div>
                                            <input type="text" class="margin-top-xs form-control {{ field_hidden }}" name="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" id="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" placeholder="{{ field_description }}" {{ field_required }} {{ field_disabled }} {{ field_size }}>

                                        {% elseif extra_option.type == 'textarea' %}
                                            <div class="checkbox margin-0">
                                                <label>
                                                    <input type="checkbox" data-target="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" {{ field_required }} {{ field_checked }}>
                                                    {{ extra_option.title }}{{ extra_option.price ? ' - ' ~ extra_option.price_formatted : '' }}
                                                </label> {{ field_tip }}
                                            </div>
                                            <textarea class="form-control {{ field_hidden }} margin-top-xs" name="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" id="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" placeholder="{{ field_description }}" {{ field_required }} {{ field_disabled }} {{ field_size }}></textarea>

                                        {% elseif extra_option.type == 'select' %}
                                            <div class="checkbox margin-0">
                                                <label>
                                                    <input type="checkbox" data-target="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" {{ field_required }} {{ field_checked }}>
                                                    {{ extra_option.title }}{{ extra_option.price ? ' - ' ~ extra_option.price_formatted : '' }}
                                                </label> {{ field_tip }}
                                            </div>
                                            <select class="form-control {{ field_hidden }} margin-top-xs" name="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" id="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" {{ field_required }} {{ field_disabled }}>
                                                <option value="" selected disabled>{{ 'lang.storefront.product.extra_options.select_option'|t }}</option>
                                                {% for option in extra_option.options %}
                                                    <option value="{{ option|e }}">{{ option }}</option>
                                                {% endfor %}
                                            </select>

                                        {% elseif extra_option.type == 'checkbox' %}
                                            <div class="checkbox margin-0">
                                                <label>
                                                    <input type="checkbox" name="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" id="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" value="1" {{ field_required }}>
                                                    {{ extra_option.title }}{{ extra_option.price ? ' - ' ~ extra_option.price_formatted : '' }}
                                                </label> {{ field_tip }}
                                            </div>

                                        {% elseif extra_option.type == 'date' %}
                                            <div class="checkbox margin-0">
                                                <label>
                                                    <input type="checkbox" data-target="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" {{ field_required }} {{ field_checked }}>
                                                    {{ extra_option.title }}{{ extra_option.price ? ' - ' ~ extra_option.price_formatted : '' }}
                                                </label> {{ field_tip }}
                                            </div>
                                            <input type="text" data-datepicker class="form-control {{ field_hidden }} margin-top-xs" name="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" id="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" placeholder="{{ field_description }}" {{ field_required }} {{ field_disabled }} {{ field_size }}>

                                        {% elseif extra_option.type == 'color' %}
                                            <div class="checkbox margin-0">
                                                <label>
                                                    <input type="checkbox" data-target="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" {{ field_required }} {{ field_checked }}>
                                                    {{ extra_option.title }}{{ extra_option.price ? ' - ' ~ extra_option.price_formatted : '' }} <span class="extra-option-option-label hidden">- <span></span></span>
                                                </label> {{ field_tip }}
                                            </div>
                                            <div class="list-colors {{ field_hidden }}" name="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}">
                                                {% for option in extra_option.options %}
                                                    {% set option_background = option.type == 'color' ? 'background:'~ option.color ~';' : 'background:url('~ option.file.images.square ~') center / contain no-repeat;' %}
                                                    <label for="{{ extra_option.alias ~ '_' ~ loop.index0 }}" class="relative badge badge-md extra-option-badge margin-top-xs margin-right-xxs" data-toggle="tooltip" title="{{ option.title }}">
                                                        <div class="badge-color" style="{{ option_background }}"></div>
                                                        <input type="radio" name="{{ 'extra_options[' ~ extra_option.alias ~ ']' }}" id="{{ extra_option.alias ~ '_' ~ loop.index0 }}" value="{{ option.title }}" {{ field_required }} {{ field_disabled }} {{ field_size }}>
                                                    </label>
                                                {% endfor %}
                                            </div>
                                        {% endif %}
                                    </div>
                                {% endfor %}
                            </div>
                        {% endif %}

                        <div class="product-price">

                            {% if product.price_on_request == true %}
                                <span class="data-product-price price">{{ 'lang.storefront.macros.product.price_on_request'|t }}</span>
                                <del class="promo-price"></del>
                            {% else %}
                                {% if product.promo == true %}
                                    <span class="data-product-price price">{{ product.price_promo | money_with_sign }}</span>
                                    <del class="promo-price margin-right-sm">{{ product.price | money_with_sign }}</del>
                                {% else %}
                                    <span class="data-product-price price">{{ product.price | money_with_sign }}</span>
                                    <del class="promo-price"></del>
                                {% endif %}
                            {% endif %}

                            <div class="data-product-info">
                                <div>
                                    {% if user.wholesale is same as(true) and product.wholesale == true and store.settings.wholesale.show_regular_price %}
                                        <div class="small">{{ 'lang.storefront.product.wholesale.regular_price'|t }} <span class="data-price-non-wholesale">{{ product.price_non_wholesale | money_with_sign }}</span></div>
                                    {% endif %}

                                    {% if product.wholesale != true or (product.wholesale == true and not user.wholesale) %}
                                        <div class="small promo-percentage {% if product.price_promo_percentage == false %}hidden{% endif %}">
                                            {{ 'lang.storefront.product.discount_info'|t([ product.price_promo_percentage == true ? product.price_promo_percentage]) }}
                                        </div>
                                    {% endif %}

                                    {% if product.tax > 0 %}
                                        {% if store.taxes_included == false %}
                                            <div class="small">{{ 'lang.storefront.product.tax.percentage_info'|t([user.l10n.tax_name, product.tax]) }}</div>
                                        {% else %}
                                            <div class="small">{{ 'lang.storefront.product.tax_included_info'|t([user.l10n.tax_name]) }}</div>
                                        {% endif %}
                                    {% endif %}
                                </div>
                            </div>
                        </div>

                        {% if product.campaign and product.campaign.campaign_layout != 'minimal_layout' %}
                            {{ generic_macros.product_campaign_block(product.campaign, product.price_vendible) }}
                        {% endif %}

                        {% if store.settings.rewards.active and store.settings.rewards.message_product %}
                            <div class="callout callout-info {{ product.rewards == 0 ? 'hidden' }}">
                                <i class="icon margin-right-xxs">{{ icons('trophy') }}</i>
                                {{ store.settings.rewards.message_product|rewards_message(product.rewards) }}
                            </div>
                        {% endif %}

                        {% if product_is_vendible %}
                            <div class="data-product-info">
                                <input type="number" class="form-control" value="1" min="1" name="qtd" {% if product.stock.stock_sold_single %} data-toggle="tooltip" data-placement="bottom" title="{{ 'lang.storefront.cart.product_limit.tooltip'|t }}" readonly {% endif %}>
                                <button type="submit" class="btn btn-primary {{ store.theme_options.button_primary_shadow }} btn-lg">{{ icons('shopping-basket') }} {{ 'lang.storefront.layout.button.buy'|t }}</button>
                            </div>
                            <div class="data-product-on-request">
                                <a href="{{ site_url("contact?p=") ~ 'lang.storefront.product.label'|t([product.title])|url_encode }}" class="btn btn-primary {{ store.theme_options.button_primary_shadow }} btn-lg price-on-request">{{ icons('envelope') }} {{ 'lang.storefront.product.contact.button'|t }}</a>
                            </div>
                        {% elseif product.status == 3 %}
                            <div class="well well-default {{ store.theme_options.well_default_shadow }}">
                                {{ 'lang.storefront.product.status.out_of_stock'|t }}
                            </div>
                        {% elseif product.status == 4 %}
                            <div class="well well-default {{ store.theme_options.well_default_shadow }}">
                                {{ 'lang.storefront.product.status.soon'|t }}
                            </div>
                        {% endif %}

                        {{ product_macros.wishlist_block(product, store) }}

                    {{ form_close() }}

                    <div id="payment-method-messaging-element"></div>

                    {% if product.tabs %}
                        <div class="panel-group product-tabs margin-top" id="product-tabs" role="tablist" aria-multiselectable="true">
                            {% if product.description or product.campaign %}
                                <div class="panel well-default">
                                    <div class="panel-heading" role="tab" id="tab_description">
                                        <h4 class="panel-title"><a role="button" data-toggle="collapse" data-parent="#product-tabs" href="#panel_description" aria-expanded="true" aria-controls="panel_description">{{ 'lang.storefront.product.description.label'|t }}</a></h4>
                                    </div>
                                    <div id="panel_description" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="tab_description">
                                        <div class="panel-body">
                                            {% if product.campaign and product.campaign.campaign_layout == 'minimal_layout' %}
                                                {{ generic_macros.product_campaign_simple(product.campaign) }}
                                            {% endif %}
                                            {{ product.description }}
                                        </div>
                                    </div>
                                </div>
                            {% endif %}

                            {% for tab in product.tabs %}
                                <div class="panel well-default">
                                    <div class="panel-heading" role="tab" id="tab_{{ tab.slug }}">
                                        <h4 class="panel-title"><a role="button" data-toggle="collapse" data-parent="#product-tabs" href="#panel_{{ tab.slug }}" aria-expanded="true" aria-controls="panel_{{ tab.slug }}">{{ tab.title }}</a></h4>
                                    </div>
                                    <div id="panel_{{ tab.slug }}" class="panel-collapse collapse" role="tabpanel" aria-labelledby="tab_{{ tab.slug }}">
                                        <div class="panel-body">{{ tab.content }}</div>
                                    </div>
                                </div>
                            {% endfor %}
                        </div>
                    {% else %}
                        <div class="product-description lead">
                            {% if product.campaign and product.campaign.campaign_layout == 'minimal_layout' %}
                                {{ generic_macros.product_campaign_simple(product.campaign) }}
                            {% endif %}
                            {{ product.description }}
                        </div>
                    {% endif %}

                    {% if product.custom_fields or product.brand or product.tags %}
                        <div class="table-product-attributes margin-bottom margin-top">
                            <div class="table-responsive">
                                <table class="table">
                                    {% if product.brand %}
                                        <tr class="product-brand">
                                            <th>{{ 'lang.storefront.product.brand.label'|t }}</th>
                                            <td><a href="{{ product.brand.url }}" class="text-underline text-link">{{ product.brand.title }}</a></td>
                                        </tr>
                                    {% endif %}

                                    {% if product.tags %}
                                        <tr class="product-tags">
                                            <th>{{ 'lang.storefront.product.tags.label'|t }}</th>
                                            <td>
                                                <ul class="list-inline list-unstyled">
                                                {% for tag in product.tags %}<li><a href="{{ tag.url }}" class="product-tag label label-outline">{{ tag.title }}</a></li>{% endfor %}
                                                </ul>
                                            </td>
                                        </tr>
                                    {% endif %}

                                    {% for custom_field in product.custom_fields %}
                                        <tr class="product-custom-fields" id="custom_field_{{ custom_field.alias }}">
                                            <th>{{ custom_field.title }}</th>
                                            <td>{% for custom_field_value in custom_field.values %}{{ custom_field_value.value }}{{ not loop.last ? ', ' }}{% endfor %}</td>
                                        </tr>
                                    {% endfor %}
                                </table>
                            </div>
                        </div>
                    {% endif %}

                    {% if product.video_embed_url %}
                        <div class="product-video visible-xs">
                            <a href="{{ product.video_url }}" class="btn btn-default {{ store.theme_options.button_default_shadow }}" target="_blank">{{ icons('external-link') }} {{ 'lang.storefront.product.video.button'|t }}</a>
                        </div>
                    {% endif %}

                    <div class="row">
                        <div class="{{ product.file ? 'col-md-6' : 'col-sm-12' }}">
                            <div class="share margin-top">
                                <h6 class="text-muted text-uppercase text-xxs">{{ 'lang.storefront.product.share.label'|t }}</h6>
                                <a target="_blank" href="http://www.facebook.com/sharer.php?u={{ product_url }}" class="text-muted">{{ icons('facebook', 'fa-lg') }}</a>
                                <a target="_blank" href="http://www.facebook.com/dialog/send?app_id=229578494202981&link={{ product_url }}&redirect_uri={{ product_url }}" class="text-muted">{{ icons('facebook-messenger', 'fa-lg') }}</a>
                                <a target="_blank" href="https://wa.me/?text={{ "#{product.title}: #{product_url}"|url_encode }}" class="text-muted">{{ icons('whatsapp', 'fa-lg') }}</a>
                                <a target="_blank" href="https://twitter.com/share?url={{ product_url }}&text={{ character_limiter(description, 100)|url_encode }}" class="text-muted">{{ icons('twitter', 'fa-lg') }}</a>
                                <a target="_blank" href="https://pinterest.com/pin/create/bookmarklet/?media={{ product.image.full }}&url={{ product_url }}&description={{ product.title|url_encode }}" class="text-muted">{{ icons('pinterest', 'fa-lg') }}</a>
                            </div>
                        </div>
                        {% if product.file %}
                            <div class="col-md-6">
                                <div class="download margin-top">
                                    <h6 class="text-muted text-uppercase text-xxs">{{ 'lang.storefront.product.download_file.label'|t }}</h6>
                                    <a target="_blank" href="{{ product.file }}" class="text-muted">{{ icons('download') }} {{ 'lang.storefront.product.download_file.button'|t }}</a>
                                </div>
                            </div>
                        {% endif %}
                    </div>

                    {% if apps.facebook_comments.comments_products %}
                        <div class="facebook-comments margin-top">
                            <div class="fb-comments" data-href="{{ product.permalink }}" data-numposts="5" data-width="100%"></div>
                        </div>
                    {% endif %}
                </div>
            </div>
        </div>
    </article>

    <div class="related-products hidden" data-load="related-products" data-href="{{ site_url('related-products') }}" data-products="{{ product.id }}" data-num-products="4" data-css-class-wrapper="product-related-products">
        <div class="{{ layout_container }}">
            <div class="text-center">
                <h3>{{ product.related_products.title }}</h3>
                <div class="related-products-placement margin-top"></div>
            </div>
        </div>
    </div>


{% endblock %}
