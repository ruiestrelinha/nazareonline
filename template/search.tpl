{#
Description: Search Page
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
        {% set get = get|merge({'order_by': store.theme_options.search_default_order}) %}
    {% endif %}

    {% set custom_fields_param = '' %}

    {% if get.filter_custom_fields %}
        {% set custom_fields_param = 'custom_fields:' ~ get.filter_custom_fields|split('|')|join(' custom_fields:') %}
    {% endif %}

    {% set search = products("search order:#{get.order_by} limit:#{products_per_page_catalog} price:[#{get.filter_price_min},#{get.filter_price_max}] tag:#{get.filter_tags} brand:#{get.filter_brands} category:#{get.filter_categories} stock:#{get.filter_stock} promo:#{get.filter_promo} new:#{get.filter_new} rating:#{get.filter_rating} #{custom_fields_param}") %}
    {% set search_default = products("search order:#{get.order_by} limit:#{products_per_page_catalog}") %}

    {% set total_products = search_default.total_results %}
    {% set cur_page = (pagination_segment / products_per_page_catalog) + 1 %}
    {% set cur_page_from = pagination_segment + 1 %}
    {% set cur_page_to = (cur_page * products_per_page_catalog) < search_default.total_results ? cur_page * products_per_page_catalog : search_default.total_results %}

    <div class="{{ layout_container }}">

        <div class="row">
            <div class="col-md-3 {{ show_search_filters }}">
                {% if search_default.results %}
                    {{ generic_macros.filters_list(null, null, null, null, get) }}
                {% endif %}

                {% set popular_products = products("search order:sales limit:3 paginate:false") %}

                {% if popular_products|length == 3 %}
                    <div class="block-popular margin-bottom hidden-xs">
                        <h3 class="block-title block-title-sm"><span>{{ 'lang.storefront.search.popular'|t }}</span></h3>
                        {% for popular_product in popular_products.results %}
                            {{ generic_macros.product_list_media(popular_product) }}
                        {% endfor %}
                    </div>
                {% endif %}
            </div>

            <div class="col-md-{{ show_search_filters == 'show' ? '9' : '12' }}">

                <h1 class="title">{{ 'lang.storefront.search.title'|t }}</h1>

                {% if search_default.results %}
                    {{ generic_macros.order_by(get, order_options) }}
                {% endif %}

                <div class="clearfix"></div>

                <div class="search-message">
                    {% if search_default.results %}
                        {{ 'lang.storefront.search.results'|t([cur_page_from, cur_page_to, total_products, search.query]) }}
                    {% else %}
                        {{ 'lang.storefront.search.results.variant'|t([search.total_results, search.query]) }}
                    {% endif %}
                </div>

                <div class="products margin-top">
                    <div class="row">
                        {% if search.results %}
                                {% for product in search.results %}
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
                                {{ pagination("search limit:#{products_per_page_catalog} price:[#{get.filter_price_min},#{get.filter_price_max}] tag:#{get.filter_tags} brand:#{get.filter_brands} category:#{get.filter_categories} stock:#{get.filter_stock} promo:#{get.filter_promo} new:#{get.filter_new} rating:#{get.filter_rating} #{custom_fields_param}") }}
                            </nav>
                        {% else %}
                            <div class="col-xs-12">
                                <h4 class="margin-bottom-lg margin-top-0 text-muted-dark light">{{ 'lang.storefront.product_list.no_products'|t }}</h4>
                            </div>
                        {% endif %}
                    </div>
                </div>
            </div>

        </div>
    </div>

{% endblock %}