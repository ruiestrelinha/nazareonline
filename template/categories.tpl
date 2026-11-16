{#
Description: Categories list page
#}

{% import 'macros.tpl' as generic_macros %}

{% extends 'base.tpl' %}

{% block content %}

    {% set categories = categories("limit:#{categories_per_page}") %}

    <div class="{{ layout_container }}">

        <h1 class="title">{{ 'lang.storefront.categories.title'|t }}</h1>

        <div class="categories {{ categories_per_page }} margin-top">
            <div class="row">
                {% for category in categories %}
                    <div class="col-xs-{{ 12 / mobile_categories_per_row }} col-sm-4 col-md-{{ 12 / categories_per_row }}">
                        {{ generic_macros.category_list(category, false) }}
                    </div>
                    {% if loop.index0 % categories_per_row == (categories_per_row - 1) %}
                        <div class="clearfix hidden-xs"></div>
                    {% endif %}
                    {% if mobile_categories_per_row == 2 and (loop.index % 2 == 0) %}
                        <div class="clearfix visible-xs"></div>
                    {% endif %}
                {% else %}
                    <div class="col-xs-12">
                        <h4 class="margin-bottom-lg margin-top-0 text-muted-dark light">{{ 'lang.storefront.categories.no_categories'|t }}</h4>
                    </div>
                {% endfor %}
            </div>
        </div>

        <nav class="text-center">
            {{ pagination("categories limit:#{categories_per_page}") }}
        </nav>

    </div>

{% endblock %}