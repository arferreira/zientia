class IntroController < ApplicationController
  def index

  	if user_signed_in?
  		# caso o aluno esteja logado, redireciona-lo para o dashboard da app
  		redirect_to :controller=>'dashboard', :action => 'index'
  	else

  	end # fim do if usuario logado

  end # fim da action index


end #final do controller
