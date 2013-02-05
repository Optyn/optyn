FrontEndStaticPage::Engine.routes.draw do
	root :to => "samples#index"
	match 'aboutus'=> "samples#aboutus"
	match 'blog' => "samples#blog"
	match 'blog_post' => "samples#blog_post"
	match 'coming_soon' => "samples#coming_soon"
	match 'faq' => "samples#faq"
	match 'features' => "samples#features"
	match 'portfolio' => "samples#portfolio"
	match 'pricing' => "samples#pricing"
	match 'reset' => "samples#reset"
	match 'signin' => "samples#signin"
	match 'signup' => "samples#signup"
end
