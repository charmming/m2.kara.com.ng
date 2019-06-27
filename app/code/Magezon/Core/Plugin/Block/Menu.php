<?php
namespace Magezon\Core\Plugin\Block;

class Menu
{
	public function aroundRenderNavigation(
		\Magento\Backend\Block\Menu $menuBlock,
		callable $proceed,
		$menu, $level = 0, $limit = 0, $colBrakes = []
	) {

		foreach ($menu as $item) {
			if ($item->getId() == 'Magezon_Core::extensions' && !$item->hasChildren()) {
				$menu->remove('Magezon_Core::extensions');
				break;
			}
		}
		$result = $proceed($menu, $level, $limit, $colBrakes);

		return $result;
	}
}
