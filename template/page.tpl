{#
Description: Page
#}

{% set show_categories_col = true %}

{% import 'macros.tpl' as generic_macros %}

{% extends 'base.tpl' %}

{% block content %}

<div class="{{ layout_container }}">

    <div class="row">
        <div class="col-md-9 col-md-offset-3">

            <h1 class="title margin-bottom">{{ page.title }}</h1>

            <div class="page-content page-height">
                {{ page.content }}
            </div>
        </div>
    </div>
</div>

{% endblock %}