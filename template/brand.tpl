{#
Description: Product brand page
#}

{% import 'macros.tpl' as generic_macros %}

{% extends 'base.tpl' %}

{% block content %}

    {#  Setup order #}
    {% set order_options = { 'position' : 'lang.storefront.layout.order_options.position'|t, 'title' : 'lang.storefront.layout.order_options.title'|t, 'newest' : 'lang.storefront.layout.order_options.newest'|t, 'sales' : 'lang.storefront.layout.order_options.sales'|t, 'price_asc' : 'lang.storefront.layout.order_options.price_asc'|t, 'price_desc' : 'lang.storefront.layout.order_options.price_desc'|t, 'stock_desc' : 'lang.storefront.layout.order_options.stock_desc'|t, 'stock_asc' : 'lang.storefront.layout.order_options.stock_asc'|t, 'rating' : 'lang.storefront.layout.order_options.rating'|t } %}
    {% set query_order = get.order_by %}

    {% if not get.order_by in order_options|keys %}
        {% if not get %}
            {% set get = [] %}
        {% endif %}
        {% set get = get|merge({'order_by': store.category_default_order|default('position')}) %}
    {% endif %}

    {% set custom_fields_param = '' %}

    {% if get.filter_custom_fields %}
        {% set custom_fields_param = 'custom_fields:' ~ get.filter_custom_fields|split('|')|join(' custom_fields:') %}
    {% endif %}

    {% set products = products("order:#{get.order_by} brand:#{brand.id} limit:#{products_per_page_catalog} price:[#{get.filter_price_min},#{get.filter_price_max}] tag:#{get.filter_tags} category:#{get.filter_categories} stock:#{get.filter_stock} promo:#{get.filter_promo} new:#{get.filter_new} rating:#{get.filter_rating} #{custom_fields_param}") %}
    {% set products_default = products("order:#{get.order_by} brand:#{brand.id} limit:#{products_per_page_catalog}") %}

    <div class="{{ layout_container }}">

        <ol class="breadcrumb hidden-xs">
            <li><a href="{{ site_url() }}">{{ 'lang.storefront.layout.breadcrumb.home'|t }}</a></li>
            <li><a href="{{ site_url('brands') }}">{{ 'lang.storefront.brand.title'|t }}</a></li>
            <li class="active">
                <a href="{{ brand.url }}"><span>{{ brand.title }}</span></a>
            </li>
        </ol>

        <div class="row">
            <div class="col-md-3 {{ show_filters }}">
                {% if products_default %}
                    {{ generic_macros.filters_list(null, null, brand, null, get) }}
                {% endif %}

                {% set popular_products = products("order:sales brand:#{brand.id} limit:3 paginate:false") %}

                {% if popular_products|length == 3 %}
                    <div class="block-popular margin-bottom hidden-xs">
                        <h3 class="block-title block-title-sm"><span>{{ 'lang.storefront.brand.popular'|t }}</span></h3>
                        {% for popular_product in popular_products %}
                            {{ generic_macros.product_list_media(popular_product) }}
                        {% endfor %}
                    </div>
                {% endif %}
            </div>

            <div class="col-md-{{ show_filters == 'show' ? '9' : '12' }}">
                <h1 class="title"><a href="{{ brand.url }}" class="link-inherit">{{ brand.title }}</a></h1>

                {% if products_default %}
                    {{ generic_macros.order_by(get, order_options) }}
                {% endif %}

                <div class="clearfix"></div>

                {% if brand.description %}
                    <div class="margin-top-sm">{{ brand.description|nl2br }}</div>
                {% endif %}

                {% if brand.brand_url %}
                    <div class="margin-top-sm"><a href="{{ brand.brand_url }}" target="_blank">{{ brand.brand_url }}</a></div>
                {% endif %}

                {% if brand.manufacturer or brand.responsible or brand.importer %}
                    <div class="gpsr-brand-content well well-default {{ store.theme_options.well_default_shadow }} margin-top">
                        <div class="margin-bottom">{{ 'lang.storefront.product.tab.gpsr.title'|t }}</div>

                        {% if brand.manufacturer %}
                            <div>{{ brand.manufacturer|nl2br }}</div>
                        {% endif %}

                        {% if brand.responsible %}
                            <hr>
                            <div>{{ brand.responsible|nl2br }}</div>
                        {% endif %}

                        {% if brand.importer %}
                            <hr>
                            <div>{{ brand.importer|nl2br }}</div>
                        {% endif %}
                    </div>
                {% endif %}

                <div class="products margin-top">
                    <div class="row">
                        {% if products %}
                                {% for product in products %}
                                    <div class="col-xs-{{ mobile_products_per_row }} col-sm-6 col-md-4 col-lg-{{ 12 / products_per_row }}">
                                        {{ generic_macros.product_list(product) }}
                                    </div>
                                    {% if loop.index0 % products_per_row == (products_per_row - 1) %}
                                        <div class="clearfix visible-lg"></div>
                                    {% endif %}
                                    {% if loop.index0 % 3 == 2 %}
                                        <div class="clearfix visible-md"></div>
                                    {% endif %}
                                    {% if loop.index0 % 2 == 1 %}
									    <div class="clearfix visible-sm"></div>
                                    {% endif %}
                                    {% if mobile_products_per_row == '6' and (loop.index % 2 == 0) %}
                                        <div class="clearfix visible-xs"></div>
                                    {% endif %}
                                {% endfor %}
                        </div>

                        <div class="row">
                            <nav class="text-center">
                                {{ pagination("brand:#{brand.id} limit:#{products_per_page_catalog} price:[#{get.filter_price_min},#{get.filter_price_max}] tag:#{get.filter_tags} category:#{get.filter_categories} promo:#{get.filter_promo} new:#{get.filter_new} stock:#{get.filter_stock} rating:#{get.filter_rating} #{custom_fields_param}") }}
                            </nav>
                        {% else %}
                            <div class="col-xs-12">
                                <h4 class="margin-bottom-lg margin-top-0 text-muted-dark text-center light">{{ 'lang.storefront.brand.no_products'|t }}</h4>
                            </div>
                        {% endif %}
                    </div>
                </div>
            </div>

        </div>
    </div>

{% endblock %}