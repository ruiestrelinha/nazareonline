{#
Description: Home Page
#}

{% import 'macros.tpl' as generic_macros %}

{% extends 'base.tpl' %}

{% block content %}

    {% if categories and store.theme_options.home_num_categories > 0 %}
        <section class="home-categories">
            <div class="{{ layout_container }}">
                <div class="row">
                    {% for products_category in categories %}
                        {% if loop.index0 < (store.theme_options.home_num_categories ? store.theme_options.home_num_categories : 4) %}
                            <div class="margin-bottom {{ loop.first ? 'col-sm-offset-' ~ (12 - ((12 / store.theme_options.home_categories_per_row) * min(categories|length, store.theme_options.home_num_categories) )) / 2 }} {{ 'col-sm-' ~ (12 / store.theme_options.home_categories_per_row) }}">
                                <div class="category category-id-{{ products_category.id }}">
                                    <a href="{{ products_category.url }}" class="link-category" style="background-image:url({{ products_category.image.thumb }})">
                                        <span>{{ products_category.title }}</span>
                                    </a>
                                </div>
                            </div>
                        {% endif %}
                    {% endfor %}
                </div>
            </div>
        </section>
    {% endif %}

    {% if store.products_per_page_home %}
        {% set products_per_page_home = store.products_per_page_home %}
        {% set products_per_row_home = store.theme_options.home_products_per_row %}
        {% set products_featured = products("featured order:featured limit:#{products_per_page_home}") %}
        {% set products_new = products("new order:newest limit:#{products_per_page_home}") %}
        {% set products_on_sale = products("on_sale limit:#{products_per_page_home}") %}

        {% if products_featured or products_new or products_on_sale %}
            <section class="home-products">
                <div class="{{ layout_container }}">
                    <ul class="nav-home-products nav nav-tabs" role="tablist">
                        <li {% if not products_featured %}class="hidden"{% endif %} role="presentation" data-title="home-featured-products"><a href="#home-featured-products" class="link-inherit" aria-controls="home-featured-products" role="tab" data-toggle="tab">{{ 'lang.storefront.home.featured'|t }}</a></li>
                        <li {% if not products_new %}class="hidden"{% endif %} role="presentation" data-title="home-new-products"><a href="#home-new-products" class="link-inherit" aria-controls="home-new-products" role="tab" data-toggle="tab">{{ 'lang.storefront.home.new'|t }}</a></li>
                        <li {% if not products_on_sale %}class="hidden"{% endif %} role="presentation" data-title="home-sales-products"><a href="#home-sales-products" class="link-inherit" aria-controls="home-sales-products" role="tab" data-toggle="tab">{{ 'lang.storefront.home.sales'|t }}</a></li>
                    </ul>

                    <div class="tab-content">
                        {% if products_featured %}
                            <div id="home-featured-products" role="tabpanel" class="tab-pane fade">
                                <div class="products" data-href="{{ site_url('list-products') }}" data-parent=".tab-pane" data-pool="featured" data-limit="{{ products_per_page_home }}" data-products_per_row="{{ products_per_row_home }}" data-page="1">
                                    <div class="row">
                                    </div>
                                </div>
                            </div>
                        {% endif %}

                        {% if products_new %}
                            <div id="home-new-products" role="tabpanel" class="tab-pane fade">
                                <div class="products" data-href="{{ site_url('list-products') }}" data-parent=".tab-pane" data-pool="new" data-limit="{{ products_per_page_home }}" data-products_per_row="{{ products_per_row_home }}" data-page="1">
                                    <div class="row">
                                    </div>
                                </div>
                            </div>
                        {% endif %}

                        {% if products_on_sale %}
                            <div id="home-sales-products" role="tabpanel" class="tab-pane fade">
                                <div class="products" data-href="{{ site_url('list-products') }}" data-parent=".tab-pane" data-pool="on_sale" data-limit="{{ products_per_page_home }}" data-products_per_row="{{ products_per_row_home }}" data-page="1">
                                    <div class="row">
                                    </div>
                                </div>
                            </div>
                        {% endif %}
                    </div>

                </div>
            </section>
        {% endif %}
    {% endif %}

    <section class="block">
        <div class="{{ layout_container }}">
            <div class="row">
                {% set last_blog_posts = blog_posts("limit:3") %}

                <div class="block-bestseller {{ last_blog_posts ? 'col-sm-6 col-md-3' : 'col-sm-4' }}">
                    <h3 class="block-title"><span>{{ 'lang.storefront.layout.order_options.sales'|t }}</span></h3>

                    {% set best_sellers = products("order:sales limit:3 paginate:false") %}

                    {% for popular_product in best_sellers %}
                        {{ generic_macros.product_list_media(popular_product) }}
                    {% endfor %}
                </div>

                <div class="block-blog {{ last_blog_posts ? 'col-sm-6 col-md-3' : 'col-sm-4 hidden' }}">
                    <h3 class="block-title"><span>{{ 'lang.storefront.home.block.blog.title'|t }}</span></h3>

                    {% for post in last_blog_posts %}
                        <div class="media">
                            {% if post.image %}
                                <a class="media-left media-top" href="{{ post.url }}"><img class="lazy" src="{{ assets_url('assets/store/img/no-img.png') }}" data-src="{{ post.image.square }}" alt="{{ post.image.alt ? post.image.alt : post.title|e_attr }}" title="{{ post.title|e_attr }}" width="50"></a>
                            {% endif %}
                            <div class="media-body">
                                <h5 class="media-heading"><a href="{{ post.url }}" class="link-inherit">{{ post.title }}</a></h5>
                                <small>{{ 'lang.storefront.blog.post_date'|t([post.date|format_datetime('short', 'none')]) }}</small>
                            </div>
                        </div>
                    {% else %}
                        <p>{{ 'lang.storefront.blog.no_posts'|t }}</p>
                    {% endfor %}
                </div>

                {% if last_blog_posts %}
                    <div class="clearfix margin-bottom visible-sm"></div>
                {% endif %}

                <div class="block-contacts {{ last_blog_posts ? 'col-sm-6 col-md-3' : 'col-sm-4' }}">
                    <h3 class="block-title"><span>{{ 'lang.storefront.contacts.title'|t }}</span></h3>
                    {% if store.show_email %}
                        <h5 class="margin-bottom-xxs">{{ 'lang.storefront.form.email.label'|t }}</h5>{{ safe_mailto(store.email) }}
                    {% endif %}

                    {% if store.phone %}
                        <h5 class="margin-bottom-xxs">{{ 'lang.storefront.form.phone.label'|t }}</h5><a href="tel:{{ store.phone }}">{{ store.phone }}</a>
                    {% endif %}

                    {% if store.cellphone %}
                        <h5 class="margin-bottom-xxs">{{ 'lang.storefront.form.cellphone.label'|t }}</h5><a href="tel:{{ store.cellphone }}">{{ store.cellphone }}</a>
                    {% endif %}

                    {% if store.address %}
                        <h5 class="margin-bottom-xxs">{{ 'lang.storefront.form.address.label'|t }}</h5>{{ line_break(store.address) }}
                    {% endif %}
                </div>

                <div class="block-social {{ last_blog_posts ? 'col-sm-6 col-md-3' : 'col-sm-4' }}">
                    <h3 class="block-title"><span>{{ 'lang.storefront.home.block.social.title'|t }}</span></h3>
                    {% if apps.facebook_page %}
                        <div class="margin-bottom">
                            <div class="fb-page" data-href="{{ apps.facebook_page.facebook_url }}" data-small-header="false" data-adapt-container-width="true" data-hide-cover="false" data-show-facepile="true" data-show-posts="false"><div class="fb-xfbml-parse-ignore"><blockquote cite="{{ apps.facebook_page.facebook_url }}"><a href="{{ apps.facebook_page.facebook_url }}">{{ 'lang.storefront.layout.social.facebook'|t }}</a></blockquote></div></div>
                        </div>
                    {% else %}
                        {% if store.facebook %}
                            <p class="text-h6"><a href="{{ store.facebook }}" class="link-neutral" target="_blank">{{ icons('facebook') }} {{ 'lang.storefront.layout.social.facebook'|t }}</a></p>
                        {% endif %}
                        {% if store.twitter %}
                            <p class="text-h6"><a href="{{ store.twitter }}" class="link-neutral" target="_blank">{{ icons('twitter') }} {{ 'lang.storefront.layout.social.twitter'|t }}</a></p>
                        {% endif %}
                        {% if store.instagram %}
                            <p class="text-h6"><a href="{{ store.instagram }}" class="link-neutral" target="_blank">{{ icons('instagram') }} {{ 'lang.storefront.layout.social.instagram'|t }}</a></p>
                        {% endif %}
                        {% if store.pinterest %}
                            <p class="text-h6"><a href="{{ store.pinterest }}" class="link-neutral" target="_blank">{{ icons('pinterest') }} {{ 'lang.storefront.layout.social.pinterest'|t }}</a></p>
                        {% endif %}
                        {% if store.youtube %}
                            <p class="text-h6"><a href="{{ store.youtube }}" class="link-neutral" target="_blank">{{ icons('youtube') }} {{ 'lang.storefront.layout.social.youtube'|t }}</a></p>
                        {% endif %}
                        {% if store.linkedin %}
                            <p class="text-h6"><a href="{{ store.linkedin }}" class="link-neutral" target="_blank">{{ icons('linkedin') }} {{ 'lang.storefront.layout.social.linkedin'|t }}</a></p>
                        {% endif %}
                        {% if store.tiktok %}
                            <p class="text-h6"><a href="{{ store.tiktok }}" class="link-neutral" target="_blank">{{ icons('tiktok') }} {{ 'lang.storefront.layout.social.tiktok'|t }}</a></p>
                        {% endif %}
                        <p class="text-h6 link-social-rss"><a href="{{ site_url('rss') }}" class="link-neutral" target="_blank">{{ icons('rss') }} {{ 'lang.storefront.layout.social.rss'|t }}</a></p>
                    {% endif %}
                </div>
            </div>
        </div>
    </section>

    {% if store.featured_blocks %}
        <section class="featured-blocks">
            <div class="{{ layout_container }}">
                <div class="row">
                    {% for featured_block in store.featured_blocks %}
                        <div class="{{ loop.first ? 'col-sm-offset-' ~ (12 - 4 * store.featured_blocks|length) / 2 }} col-sm-4 col-featured-block">
                            <div class="featured-block">
                                <div style="-webkit-mask-image: url('{{ featured_block.icon }}');mask-image: url('{{ featured_block.icon }}');"></div>
                                <h4 class="bold">{{ featured_block.title }}</h4>
                                <p>{{ featured_block.description }}</p>
                            </div>
                        </div>
                    {% endfor %}
                </div>
            </div>
        </section>
    {% endif %}

    {% if apps.newsletter %}
        <section class="newsletter newsletter-block">
            <div class="{{ layout_container }}">
                <div class="row">
                    <div class="col-md-7">
                        <h4>{{ icons('paper-plane', 'fa-lg') }} <span>{{ 'lang.storefront.home.block.newsletter.title'|t }}</span></h4>
                    </div>
                    <div class="col-md-5">
                        <div class="form-rounded">

                                <div class="input-group">
                                    <input type="email" id="email_newsletter" name="email_newsletter" class="form-control" placeholder="{{ 'lang.storefront.form.email.placeholder'|t }}" required>
                                    <span class="input-group-btn">
                                        <button type="button" class="btn btn-no-shadow submit-newsletter">{{ 'lang.storefront.home.block.newsletter.subscribe'|t }}</button>
                                    </span>
                                </div>

                        </div>
                    </div>
                </div>
            </div>
        </section>
    {% endif %}

    {% if apps.instagram_feed %}
        <script>
            var instagram_url = '{{ store.username }}';
        </script>
    {% endif %}

    <section class="instagram-block"></section>

    {% set brands = brands("order:#{store.theme_options.home_brands_sorting} limit:6") %}
    {% if brands %}
        <section class="brands-block">
            <div class="{{ layout_container }}">
                <h3>{{ 'lang.storefront.home.block.brands.title'|t }}</h3>
                <div class="row">
                    {% for brand in brands %}
                        <div class="col-xs-2">
                            <a href="{{ brand.url }}" class="img-frame"><img src="{{ brand.image.thumb }}" alt="{{ brand.image.alt ? brand.image.alt : brand.title }}" title="{{ brand.title }}"></a>
                        </div>
                    {% endfor %}
                </div>
                <p class="small margin-top"><a href="{{ site_url('brands') }}" class="text-underline">{{ 'lang.storefront.brands.title'|t }}</a></p>
            </div>
        </section>
    {% endif %}

{% endblock %}