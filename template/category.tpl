{#
Description: Product category page
#}

{% import 'macros.tpl' as generic_macros %}

{% extends 'base.tpl' %}

{% block content %}

    {#  Parent category #}
    {% if category.is_parent %}
        {% set parent_category = category %}
        {% set is_parent = true %}

        {% if category.parent %}
            {% set main_parent = category(category.parent) %}
        {% else %}
            {% set main_parent = category %}
        {% endif %}
    {% else %}
        {% set parent_category = category(category.parent) %}
        {% set main_parent = category(parent_category.parent) ?: parent_category %}
    {% endif %}

    {#  Setup order #}
    {% set order_options = { 'position' : 'lang.storefront.layout.order_options.position'|t, 'title' : 'lang.storefront.layout.order_options.title'|t, 'newest' : 'lang.storefront.layout.order_options.newest'|t, 'sales' : 'lang.storefront.layout.order_options.sales'|t, 'price_asc' : 'lang.storefront.layout.order_options.price_asc'|t, 'price_desc' : 'lang.storefront.layout.order_options.price_desc'|t, 'stock_desc' : 'lang.storefront.layout.order_options.stock_desc'|t, 'stock_asc' : 'lang.storefront.layout.order_options.stock_asc'|t, 'rating' : 'lang.storefront.layout.order_options.rating'|t } %}
    {% set query_order = get.order_by %}

    {% if not get.order_by in order_options|keys %}
        {% if not get %}
            {% set get = [] %}
        {% endif %}
        {% set get = get|merge({'order_by': store.category_default_order|default('position')}) %}
    {% endif %}

    {% set category_param = category.id %}

    {% if get.filter_categories %}
        {% set category_param = get.filter_categories %}
    {% endif %}

    {% set custom_fields_param = '' %}

    {% if get.filter_custom_fields %}
        {% set custom_fields_param = 'custom_fields:' ~ get.filter_custom_fields|split('|')|join(' custom_fields:') %}
    {% endif %}

    {% set products = products("order:#{get.order_by} category:[#{category_param}] limit:#{products_per_page_catalog} price:[#{get.filter_price_min},#{get.filter_price_max}] tag:#{get.filter_tags} brand:#{get.filter_brands} stock:#{get.filter_stock} promo:#{get.filter_promo} new:#{get.filter_new} rating:#{get.filter_rating} #{custom_fields_param}") %}
    {% set products_default = products("order:#{get.order_by} category:#{category.id} limit:#{products_per_page_catalog}") %}

    <div class="{{ layout_container }}">

        <ol class="breadcrumb hidden-xs">
            <li><a href="{{ site_url() }}">{{ 'lang.storefront.layout.breadcrumb.home'|t }}</a></li>
            {% if main_parent and main_parent.id != category.id %}
                <li>
                    <a href="{{ main_parent.url }}"><span>{{ main_parent.title }}</span></a>
                </li>
            {% endif %}
            {% if category.id != parent_category.id and parent_category.is_parent and parent_category.is_child %}
                <li>
                    <a href="{{ parent_category.url }}"><span>{{ parent_category.title }}</span></a>
                </li>
            {% endif %}
            <li class="active">
                <a href="{{ category.url }}"><span>{{ category.title }}</span></a>
            </li>
        </ol>

        <div class="row">
            <div class="col-md-3 {{ show_filters }}">
                {% if products_default %}
                    {{ generic_macros.filters_list(category, null, null, null, get) }}
                {% endif %}

                {% if main_parent.children and not products %}
                    <div class="panel well-featured margin-bottom panel-categories {{ store.theme_options.well_featured_shadow }}">

                        <div class="panel-heading">
                            <a href="{{ main_parent.url }}" class="link-inherit">{{ main_parent.title }}</a>
                        </div>

                        <div class="list-group">

                            {% for sub_category in main_parent.children %}

                                {% if sub_category.children %}
                                    <a data-toggle="collapse" href="{{ '#category_' ~ sub_category.id }}" data-href="{{ sub_category.url }}" aria-expanded="{{ (sub_category.id == category.id or sub_category.id == category.parent) ? 'true' :'false' }}" aria-controls="{{ 'category_' ~ sub_category.id }}" target="{{ '#category_' ~ sub_category.id }}" class="list-group-item {{ sub_category.id == category.id ? 'active' }}">
                                        {{ sub_category.title }} <span class="caret"></span>
                                    </a>

                                    <div class="nav-subcategories collapse {{ (sub_category.id == category.id or sub_category.id == category.parent) ? 'in' }}" role="menu" id="category_{{ sub_category.id }}">
                                        <ul >
                                            {% for children in sub_category.children %}
                                                <li  class="{{ (category.id == children.id) ? 'active' }} menu-{{ children.handle }}">
                                                    <a href="{{ children.url }}">{{ children.title }} <span class="total-products text-muted">({{ children.total_products }})</span></a>
                                                </li>
                                            {% endfor %}
                                        </ul>
                                    </div>
                                {% else %}
                                    <a href="{{ sub_category.url }}" class="list-group-item {{ sub_category.id == category.id ? 'active' }}">
                                        {{ sub_category.title }} <span class="total-products text-muted">({{ sub_category.total_products }})</span>
                                    </a>
                                {% endif %}

                            {% endfor %}

                        </div>
                    </div>
                {% endif %}

                {% set popular_products = products("order:sales category:#{category.id} limit:3 paginate:false") %}

                {% if popular_products|length == 3 %}
                    <div class="block-popular margin-bottom hidden-xs">
                        <h3 class="block-title block-title-sm"><span>{{ 'lang.storefront.category.popular'|t }}</span></h3>
                        {% for popular_product in popular_products %}
                            {{ generic_macros.product_list_media(popular_product) }}
                        {% endfor %}
                    </div>
                {% endif %}

            </div>

            <div class="col-md-{{ show_filters == 'show' ? '9' : '12' }}">
                <h1 class="title"><a href="{{ category.url }}" class="link-inherit">{{ category.title }}</a></h1>

                {% if products_default %}
                    {{ generic_macros.order_by(get, order_options) }}
                {% endif %}

                <div class="clearfix"></div>

                {% if category.description %}
                    <div class="margin-top-sm">{{ category.description }}</div>
                {% endif %}

                {% if products %}
                    <div class="products margin-top">
                        <div class="row">
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
                    </div>

                    <nav class="text-center">
                        {{ pagination("category:#{category.id} limit:#{products_per_page_catalog} price:[#{get.filter_price_min},#{get.filter_price_max}] tag:#{get.filter_tags} brand:#{get.filter_brands} stock:#{get.filter_stock} promo:#{get.filter_promo} new:#{get.filter_new} rating:#{get.filter_rating} #{custom_fields_param}") }}
                    </nav>

                {% elseif is_parent and parent_category.children %}

                    {% set sub_categories = categories("parent:#{parent_category.id} limit:#{categories_per_page}") %}

                    <div class="categories margin-top">
                        <div class="row">
                            {% for category in sub_categories %}
                                <div class="col-xs-{{ 12 / mobile_categories_per_row }} col-sm-4 col-md-{{ 12 / categories_per_row }}">
                                    {{ generic_macros.category_list(category) }}
                                </div>
                                {% if loop.index0 % categories_per_row == (categories_per_row - 1) %}
                                    <div class="clearfix hidden-xs"></div>
                                {% endif %}
                                {% if mobile_categories_per_row == 2 and (loop.index % 2 == 0) %}
                                    <div class="clearfix visible-xs"></div>
                                {% endif %}
                            {% endfor %}
                        </div>
                    </div>

                    <nav class="text-center">
                        {{ pagination("categories parent:#{parent_category.id} limit:#{categories_per_page}") }}
                    </nav>

                {% else %}
                    <div class="row margin-top">
                        <div class="col-xs-12">
                            <h4 class="margin-bottom-lg margin-top-0 text-muted-dark text-center light">{{ 'lang.storefront.category.no_products'|t }}</h4>
                        </div>
                    </div>

                {% endif %}

            </div>
        </div>

    </div>

{% endblock %}