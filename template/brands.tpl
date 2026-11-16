{#
Description: Brands list page
#}

{% import 'macros.tpl' as generic_macros %}

{% extends 'base.tpl' %}

{% block content %}

    {% set brands = brands("order:#{store.brands_sorting} limit:#{brands_per_page}") %}

    <div class="{{ layout_container }}">

        <h1 class="title">{{ 'lang.storefront.brands.title'|t }}</h1>

        <div class="brands margin-top">
            <div class="row">
                {% set card_hover_effect = store.theme_options.card_hover_effect != 'none' ? store.theme_options.card_hover_effect : '' %}
                {% set card_thumbnail_type = store.theme_options.catalog_thumbail_type == 'square' ? 'square' : 'thumb' %}
                {% for brand in brands %}
                    <div class="col-xs-{{ 12 / mobile_brands_per_row }} col-sm-4 col-md-{{ 12 / brands_per_row }}">
                        <article class="brand-list brand-id-{{ brand.id }} {{ store.theme_options.card_shadow }} {{ card_hover_effect }}">
                            <div class="brand-wrapper">
                                <a href="{{ brand.url }}"><img src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ brand.image[card_thumbnail_type] }}" alt="{{ brand.title }}" title="{{ brand.title }}" class="lazy" width="400" height="400"></a>
                                <div class="brand-list-details">
                                    <h3><a href="{{ brand.url }}" class="link-inherit">{{ brand.title }}</a></h3>
                                </div>
                                <div class="brand-list-expand {{ store.theme_options.card_shadow }}">
                                    <a href="{{ brand.url }}" class="btn btn-primary {{ store.theme_options.button_primary_shadow }}">{{ icons('plus-square') }} {{ 'lang.storefront.macros.button.explore'|t }}</a>
                                </div>
                            </div>
                        </article>
                    </div>
                    {% if loop.index0 % brands_per_row == (brands_per_row - 1) %}
                        <div class="clearfix hidden-xs"></div>
                    {% endif %}
                    {% if mobile_brands_per_row == 2 and (loop.index % 2 == 0) %}
                        <div class="clearfix visible-xs"></div>
                    {% endif %}
                {% else %}
                    <div class="col-xs-12">
                        <h4 class="margin-bottom-lg margin-top-0 text-muted-dark light">{{ 'lang.storefront.brands.no_brands'|t }}</h4>
                    </div>
                {% endfor %}
            </div>
        </div>

        <nav class="text-center">
            {{ pagination("brands limit:#{brands_per_page}") }}
        </nav>

    </div>

{% endblock %}