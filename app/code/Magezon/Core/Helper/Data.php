<?php
/**
 * Magezon
 *
 * This source file is subject to the Magezon Software License, which is available at https://www.magezon.com/license/.
 * Do not edit or add to this file if you wish to upgrade the to newer versions in the future.
 * If you wish to customize this module for your needs.
 * Please refer to https://magento.com for more information.
 *
 * @category  Magezon
 * @package   Magezon_Core
 * @copyright Copyright (C) 2018 Magezon (https://www.magezon.com)
 */

namespace Magezon\Core\Helper;

class Data extends \Magento\Framework\App\Helper\AbstractHelper
{
    /**
     * @var \Magento\Store\Model\StoreManagerInterface
     */
    protected $_storeManager;

    /**
     * @var \Magento\Cms\Model\Template\FilterProvider
     */
    protected $_filterProvider;

    /**
     * @var \Magezon\Builder\Serialize\Serializer\Json
     */
    protected $serializer;

    /**
     * @param \Magento\Framework\App\Helper\Context      $context        
     * @param \Magento\Store\Model\StoreManagerInterface $storeManager   
     * @param \Magento\Cms\Model\Template\FilterProvider $filterProvider 
     * @param \Magezon\Builder\Serialize\Serializer\Json $serializer     
     */
    public function __construct(
        \Magento\Framework\App\Helper\Context $context,
        \Magento\Store\Model\StoreManagerInterface $storeManager,
        \Magento\Cms\Model\Template\FilterProvider $filterProvider,
        \Magezon\Core\Framework\Serialize\Serializer\Json $serializer
    ) {
        parent::__construct($context);
        $this->_storeManager   = $storeManager;
        $this->_filterProvider = $filterProvider;
        $this->serializer      = $serializer;
    }
   
    public function filter($str)
    {
        $storeId = $this->_storeManager->getStore()->getId();
        return $this->_filterProvider->getBlockFilter()->setStoreId($storeId)->filter($str);
    }

    public function unserialize($string)
    {
        if ($string && $this->isJSON($string)) {
            return $this->serializer->unserialize($string);
        }
        return $string;
    }

    public function serialize($array = [])
    {
        return $this->serializer->serialize($array);
    }

    /**
     * @param  string  $string
     * @return boolean
     */
    public function isJSON($string)
    {
        return is_string($string) && is_array(json_decode($string, true)) ? true : false;
    }

    /**
     * @return string
     */
    public function getMediaUrl()
    {
        $mediaUrl = $this->_storeManager->getStore()->getBaseUrl(
            \Magento\Framework\UrlInterface::URL_TYPE_MEDIA
        );
        return $mediaUrl;
    }

    /**
     * Remove base url
     */
    public function convertImageUrl($string)
    {
        $mediaUrl = $this->getMediaUrl();
        return str_replace($mediaUrl, '', $string);
    }

    /**
     * @return boolean
     */
    public function startsWith($haystack, $needle)
    {
        $length = strlen($needle);
        return (substr($haystack, 0, $length) === $needle);
    }

    /**
     * @return boolean
     */
    public function endsWith($haystack, $needle)
    {
        $length = strlen($needle);

        return $length === 0 ||
        (substr($haystack, -$length) === $needle);
    }


    public function getImageUrl($string)
    {
        if (is_string($string) && $this->startsWith($string, 'wysiwyg') && (strpos($string, '<div') === false)) {
            $mediaUrl = $this->getMediaUrl();
            $string   = $mediaUrl . $string;
        }
        return $string;
    }

    /**
     * Convert string to numbder
     */
    public function dataPreprocessing($data)
    {
        if (is_array($data)) {
            foreach ($data as &$_row) {
                $_row = $this->unserialize($_row);
                if ($_row === '1' || $_row === '0') {
                    $_row = (int) $_row;
                }
                $_row = $this->getImageUrl($_row);
                if (is_array($_row)) {
                    $_row = $this->dataPreprocessing($_row);
                }
            }
        }
        return $data;
    }
}
