<?
namespace \vini\app
use

class twigExtension extends \Twig\Extension\AbstractExtension
{
	private function format_color($number){
		$cor = ($numero > 0) ? 'text-success':'text-danger';
		return "<span class=\"$cor\">$number</span>";
	}
}
